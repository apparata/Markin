//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

struct MarkinListView: View {
    
    let element: ListElement
    
    let level: Int
        
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(element.entries as [BlockElement], id: \.self) { entry in
                Group {
                    if entry is ListElement {
                        MarkinListView(element: entry as! ListElement, level: self.level + 1)
                    } else if entry is ParagraphElement {
                        HStack {
                            Text(self.element.isOrdered ? "1." : "•")
                                .fontWeight(self.element.isOrdered ? .bold : .black)
                                .font(.system(size: self.element.isOrdered ? 14 : 16))
                                .lineSpacing(2)
                                .padding(.bottom, 8)
                            MarkinParagraphView(element: entry as! ParagraphElement)
                                .font(.system(size: 15))
                                .lineSpacing(2)
                                .padding(.bottom, 8)
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

