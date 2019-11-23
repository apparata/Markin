//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinDocumentView: View {
    
    public let element: DocumentElement
    
    @ObservedObject public var style: MarkinStyle
        
    public init(element: DocumentElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(element.blocks, id: \.self) { block in
                Group {
                    if block is BlockQuoteElement {
                        MarkinBlockQuoteView(element: block as! BlockQuoteElement, style: self.style)
                            .padding(.bottom, self.style.spacing)
                    } else if block is CodeBlockElement  {
                        MarkinCodeBlockView(element: block as! CodeBlockElement, style: self.style)
                            .padding(.bottom, self.style.spacing)
                    } else if block is HeaderElement {
                        MarkinHeaderView(element: block as! HeaderElement, style: self.style)
                    } else if block is HorizontalRuleElement {
                        MarkinHorizontalRuleView(element: block as! HorizontalRuleElement, style: self.style)
                            .padding(.bottom, self.style.spacing)
                    } else if block is ListElement {
                        MarkinListView(element: block as! ListElement, level: 1, style: self.style)
                            .padding(.bottom, self.style.spacing)
                    } else if block is ParagraphElement {
                        MarkinParagraphView(element: block as! ParagraphElement, style: self.style)
                            .font(self.style.body.font)
                            .lineSpacing(2)
                            .padding(.bottom, self.style.spacing)
                    } else if block is TableOfContentsElement {
                        MarkinTableOfContentsView(element: block as! TableOfContentsElement,
                                                  document: self.element,
                                                  style: self.style)
                    }
                }
            }
        }.environmentObject(style)
    }
}

#endif
