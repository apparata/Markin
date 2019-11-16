//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinView: View {
    
    public let document: DocumentElement
    
    public var body: some View {
        ScrollView {
            MarkinDocumentView(element: document)
                .padding()
                .padding()
        }
    }
}

#endif
