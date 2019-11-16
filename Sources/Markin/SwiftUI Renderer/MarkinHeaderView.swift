//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinHeaderView: View {
    
    public let element: HeaderElement
    
    public init(element: HeaderElement) {
        self.element = element
    }
    
    public var body: some View {
        MarkinParagraphView(element: element.content)
            .font(headerFont(level: element.level))
            .padding(padding(at: element.level))
    }
    
    private func headerFont(level: Int) -> Font {
        switch level {
        case 1: return Font.largeTitle.weight(.bold)
        case 2: return Font.title.weight(.bold)
        case 3: return Font.headline.weight(.semibold)
        case 4: return Font.subheadline.weight(.semibold)
        case 5: return Font.body.weight(.bold)
        case 6: return Font.caption.weight(.bold)
        default: return Font.body.weight(.semibold)
        }
    }
    
    private func padding(at level: Int) -> EdgeInsets {
        switch level {
        case 1: return EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        case 2: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        case 3: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        case 4: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        case 5: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        case 6: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        default: return EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)
        }
    }
}

#endif

