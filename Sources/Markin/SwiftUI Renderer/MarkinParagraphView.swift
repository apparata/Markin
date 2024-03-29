//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinParagraphView: View {
    
    public let element: ParagraphElement
    
    @ObservedObject public var style: MarkinStyle

    public init(element: ParagraphElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        let (paragraph, link) = makeParagraph()
        if let url = link, #available(iOS 14, macOS 11, *) {
            Link(destination: url, label: {
                HStack {
                    ForEach(paragraph, id: \.self) { textOrImage in
                        textOrImage.view
                            .lineLimit(nil)
                            // Workaround, or the text will be truncated
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            })
        } else {
            HStack {
                ForEach(paragraph, id: \.self) { textOrImage in
                    textOrImage.view
                        .lineLimit(nil)
                        // Workaround, or the text will be truncated
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func makeParagraph() -> ([TextOrImage], URL?) {
        var textOrImages: [TextOrImage] = []
        var text: Text?
        var link: URL?
        for subelement in element.content {
            link = subelement.extractLink()
            if let subtext = subelement.makeText(style: style) {
                if let accumulatedText = text {
                    text = accumulatedText + subtext
                } else {
                    text = subtext
                }
            } else if let image = subelement.makeImage() {
                if let accumulatedText = text {
                    textOrImages.append(TextOrImage(accumulatedText))
                    text = nil
                }
                textOrImages.append(TextOrImage(image, isCentered: false))
            }
        }
        if let accumulatedText = text {
            textOrImages.append(TextOrImage(accumulatedText))
        }
        
        if textOrImages.containsOnly(where: { $0.isImage }) {
            for textOrImage in textOrImages {
                textOrImage.isImageCentered = true
            }
        }
        return (textOrImages, link)
    }
}

class TextOrImage: Hashable {
    
    var isText: Bool {
        text != nil
    }
    var text: Text?
    init(_ text: Text) {
        self.text = text
    }
    
    var isImage: Bool {
        image != nil
    }
    var image: Image?
    var isImageCentered: Bool = true
    init(_ image: Image, isCentered: Bool) {
        self.image = image
        isImageCentered = isCentered
    }
        
    var view: some View {
        return Group {
            if isText {
                self.text!
            } else if isImage {
                if isImageCentered {
                    VStack {
                        self.image!
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    self.image!
                }
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: TextOrImage, rhs: TextOrImage) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

protocol MarkinTextOrImageConvertible {
    /// We will only support one link per paragraph.
    func extractLink() -> URL?
    func makeText(style: MarkinStyle) -> Text?
    func makeImage() -> Image?
}

extension InlineElement: MarkinTextOrImageConvertible {
    
    func extractLink() -> URL? {
        switch self {
        case let element as LinkElement:
            return URL(string: element.url)
        default:
            return nil
        }
    }
    
    func makeText(style: MarkinStyle) -> Text? {
        switch self {
        case let element as BoldElement:
            return element.content.makeText(style: style)?.fontWeight(.bold)
        case let element as CodeElement:
            return Text(element.content)
                .font(style.code.font)
                .foregroundColor(style.code.color)
        case let element as ItalicElement:
            return element.content.makeText(style: style)?.italic()
        case let element as LinkElement:
            return Text(element.content)
                .foregroundColor(Color.blue)
                .underline(true, color: Color.blue)
        case let element as TextElement:
            return Text(element.content.trimmingCharacters(in: .newlines))
        default:
            return nil
        }
    }
    
    func makeImage() -> Image? {
        switch self {
        case let element as ImageElement:
            _ = element
            return Image(element.url)
        default:
            return nil
        }
    }
}

extension Array {
    func containsOnly(where condition: (Element) throws -> Bool) rethrows -> Bool {
        for element in self {
            if try !condition(element) {
                return false
            }
        }
        return true
    }
}

#endif
