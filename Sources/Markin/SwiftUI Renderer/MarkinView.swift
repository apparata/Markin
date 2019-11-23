//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinView: View {
    
    public let document: DocumentElement
    
    @ObservedObject public var style: MarkinStyle
    
    public init(document: DocumentElement, style: MarkinStyle) {
        self.document = document
        self.style = style
    }
    
    public var body: some View {
        ScrollView {
            MarkinDocumentView(element: document, style: style)
                .padding()
                .padding()
        }
    }
}

#endif
