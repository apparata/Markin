//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

struct MarkinView: View {
    
    let document: DocumentElement
    
    var body: some View {
        ScrollView {
            MarkinDocumentView(element: document)
                .padding()
                .padding()
        }
    }
}

#endif
