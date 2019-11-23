//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinDocumentView: View {
    
    public let element: DocumentElement
    
    @EnvironmentObject var style: MarkinStyle
    
    public init(element: DocumentElement) {
        self.element = element
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(element.blocks, id: \.self) { block in
                Group {
                    if block is BlockQuoteElement {
                        MarkinBlockQuoteView(element: block as! BlockQuoteElement)
                            .padding(.bottom, 16)
                    } else if block is CodeBlockElement  {
                        MarkinCodeBlockView(element: block as! CodeBlockElement)
                            .padding(.bottom, 16)
                    } else if block is HeaderElement {
                        MarkinHeaderView(element: block as! HeaderElement)
                    } else if block is HorizontalRuleElement {
                        MarkinHorizontalRuleView(element: block as! HorizontalRuleElement)
                            .padding(.bottom, 16)
                    } else if block is ListElement {
                        MarkinListView(element: block as! ListElement, level: 1)
                            .padding(.bottom, 16)
                    } else if block is ParagraphElement {
                        MarkinParagraphView(element: block as! ParagraphElement)
                            .font(self.style.body.font)
                            .lineSpacing(2)
                            .padding(.bottom, 16)
                    } else if block is TableOfContentsElement {
                        MarkinTableOfContentsView(element: block as! TableOfContentsElement,
                                                  document: self.element)
                    }
                }
            }
        }
    }
}

#endif
