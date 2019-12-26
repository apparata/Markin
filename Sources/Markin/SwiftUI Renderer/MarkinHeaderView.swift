//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI

public struct MarkinHeaderView: View {
    
    public let element: HeaderElement
    
    @ObservedObject public var style: MarkinStyle

    public init(element: HeaderElement, style: MarkinStyle) {
        self.element = element
        self.style = style
    }
    
    public var body: some View {
        MarkinParagraphView(element: element.content, style: style)
            .font(headerFont(level: element.level))
            .foregroundColor(headerTextColor(level: element.level))
            .padding(padding(at: element.level))
    }
    
    private func headerFont(level: Int) -> Font {
        switch level {
        case 1: return style.header1.font
        case 2: return style.header2.font
        case 3: return style.header3.font
        case 4: return style.header4.font
        case 5: return style.header5.font
        case 6: return style.header6.font
        default: return style.header6.font
        }
    }

    private func headerTextColor(level: Int) -> Color {
        switch level {
        case 1: return style.header1.textColor
        case 2: return style.header2.textColor
        case 3: return style.header3.textColor
        case 4: return style.header4.textColor
        case 5: return style.header5.textColor
        case 6: return style.header6.textColor
        default: return style.header6.textColor
        }
    }

    private func padding(at level: Int) -> EdgeInsets {
        switch level {
        case 1: return style.header1.padding
        case 2: return style.header2.padding
        case 3: return style.header3.padding
        case 4: return style.header4.padding
        case 5: return style.header5.padding
        case 6: return style.header6.padding
        default: return style.header6.padding
        }
    }
}

#endif

