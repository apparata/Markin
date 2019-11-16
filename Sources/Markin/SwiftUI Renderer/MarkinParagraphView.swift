//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinParagraphView: View {
    
    public let element: ParagraphElement
    
    public init(element: ParagraphElement) {
        self.element = element
    }
    
    public var body: some View {
        HStack {
            ForEach(makeParagraph(), id: \.self) { textOrImage in
                textOrImage.view
                    .lineLimit(nil)
                    // Workaround, or the text will be truncated
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
        
    private func makeParagraph() -> [TextOrImage] {
        var textOrImages: [TextOrImage] = []
        var text: Text?
        for subelement in element.content {
            if let subtext = subelement.makeText() {
                if let accumulatedText = text {
                    text = accumulatedText + Text(" ") + subtext
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
        return textOrImages
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
    func makeText() -> Text?
    func makeImage() -> Image?
}

extension InlineElement: MarkinTextOrImageConvertible {
    
    func makeText() -> Text? {
        switch self {
        case let element as BoldElement:
            return element.content.makeText()?.fontWeight(.bold)
        case let element as CodeElement:
            return Text(element.content)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(Color.purple)
        case let element as ItalicElement:
            return element.content.makeText()?.italic()
        case let element as LinkElement:
            return Text(element.content)
                .foregroundColor(Color.blue)
                .underline(true, color: Color.blue)
        case let element as TextElement:
            return Text(element.content.trimmingCharacters(in: .whitespacesAndNewlines))
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
