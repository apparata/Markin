//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinListView: View {
    
    public let element: ListElement
    
    public let level: Int
    
    @ObservedObject public var style: MarkinStyle

    public init(element: ListElement, level: Int, style: MarkinStyle) {
        self.element = element
        self.level = level
        self.style = style
    }
        
    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(element.entries as [BlockElement], id: \.self) { entry in
                Group {
                    if entry is ListElement {
                        MarkinListView(element: entry as! ListElement, level: self.level + 1, style: self.style)
                    } else if entry is ParagraphElement {
                        HStack {
                            Text(self.element.isOrdered ? "1." : "•")
                                .fontWeight(self.element.isOrdered ? .bold : .black)
                                .font(self.element.isOrdered ? self.style.list.orderedBulletFont
                                                             : self.style.list.bulletFont)
                                .lineSpacing(2)
                                .padding(.bottom, self.style.list.spacing)
                            MarkinParagraphView(element: entry as! ParagraphElement, style: self.style)
                                .font(self.style.list.font)
                                .lineSpacing(2)
                                .padding(.bottom, self.style.list.spacing)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: level == 1 ? 8 : 0,
                            leading: CGFloat(level * 8),
                            bottom: 0,
                            trailing: 8))
    }
}

#endif

