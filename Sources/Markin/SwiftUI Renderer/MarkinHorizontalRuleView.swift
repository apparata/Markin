//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinHorizontalRuleView: View {
    
    public let element: HorizontalRuleElement
    
    @ObservedObject public var style: MarkinStyle
        
    public init(element: HorizontalRuleElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        Divider()
    }
}

#endif
