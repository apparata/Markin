//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinBlockQuoteView: View {
    
    public let element: BlockQuoteElement
    
    @ObservedObject public var style: MarkinStyle
    
    public init(element: BlockQuoteElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(element.content, id: \.self) { paragraph in
                MarkinParagraphView(element: paragraph, style: self.style)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(
            ZStack {
                style.blockQuote.color.opacity(0.1)
                HStack {
                    self.style.blockQuote.color.frame(maxWidth: 4)
                    Spacer()
                }
            }
        )
    }
}

#endif
