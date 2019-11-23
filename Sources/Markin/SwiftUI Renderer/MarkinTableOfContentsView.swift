//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinTableOfContentsView: View {
    
    public let element: TableOfContentsElement
    
    public let document: DocumentElement
    
    @ObservedObject public var style: MarkinStyle

    public init(element: TableOfContentsElement,
                document: DocumentElement,
                style: MarkinStyle) {
        self.element = element
        self.document = document
        self.style = style
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            ForEach(makeTOC(), id: \.self) { entry in
                HStack {
                    Text("•")
                        .fontWeight(.black)
                        .font(.system(size: 16))
                        .lineSpacing(0)
                        .padding(.bottom, 4)
                        .padding(.leading, CGFloat(16 * (entry.level - 1)))
                    Text(entry.text)
                        .font(.system(size: 15))
                        .lineSpacing(0)
                        .padding(.bottom, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private func makeTOC() -> [TOCEntry] {
        let headers = document.blocks.compactMap { $0 as? HeaderElement}
        var entries: [TOCEntry] = []
        for header in headers {
            let text = header.content.formatAsText()
            entries.append(TOCEntry(text: text, level: header.level))
        }
        return entries
    }
}

private class TOCEntry: Hashable {
    
    let text: String
    let level: Int
    
    init(text: String, level: Int) {
        self.text = text
        self.level = level
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: TOCEntry, rhs: TOCEntry) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

#endif
