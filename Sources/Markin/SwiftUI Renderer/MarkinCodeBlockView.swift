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
        Text(element.content)
            .font(style.codeBlock.font)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.sRGB, white: 0.0, opacity: 0.05))
            // Workaround, or the text will be truncated
            .fixedSize(horizontal: false, vertical: true)
    }
}

#endif
