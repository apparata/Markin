//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinBlockQuoteView: View {
    
    public let element: BlockQuoteElement
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(element.content, id: \.self) { paragraph in
                MarkinParagraphView(element: paragraph)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(
            ZStack {
                Color.yellow.opacity(0.1)
                HStack {
                    Color.yellow.frame(maxWidth: 4)
                    Spacer()
                }
            }
        )
    }
}

#endif
