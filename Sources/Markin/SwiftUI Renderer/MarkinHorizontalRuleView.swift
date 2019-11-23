//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinHorizontalRuleView: View {
    
    public let element: HorizontalRuleElement
        
    public init(element: HorizontalRuleElement) {
        self.element = element
    }
    
    public var body: some View {
        Divider()
    }
}

#endif
