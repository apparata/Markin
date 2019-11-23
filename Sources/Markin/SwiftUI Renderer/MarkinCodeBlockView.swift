//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinCodeBlockView: View {
    
    public let element: CodeBlockElement
    
    @ObservedObject public var style: MarkinStyle
    
    public init(element: CodeBlockElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        makeText()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(style.codeBlock.background)
            // Workaround, or the text will be truncated
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func makeText() -> Text {
        if let text = style.codeBlock.formatter?(element) {
            return text
        } else {
            return Text(element.content)
                .font(style.codeBlock.font)
        }
    }
}

#endif
