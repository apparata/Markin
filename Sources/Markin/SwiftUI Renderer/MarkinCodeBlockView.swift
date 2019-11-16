//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

struct MarkinCodeBlockView: View {
    
    let element: CodeBlockElement
    
    var body: some View {
        Text(element.content)
            .font(.system(size: 13, weight: .regular, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.sRGB, white: 0.0, opacity: 0.05))
            // Workaround, or the text will be truncated
            .fixedSize(horizontal: false, vertical: true)
    }
}

#endif
