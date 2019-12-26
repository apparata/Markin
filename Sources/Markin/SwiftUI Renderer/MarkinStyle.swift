//
//  Copyright © 2019 Apparata AB. All rights reserved.
//

import SwiftUI

public struct HeaderStyle {
    
    public var font: Font
    public var textColor: Color
    public var padding: EdgeInsets
    
    public init(font: Font = Font.largeTitle.weight(.bold),
                textColor: Color = Color.primary,
                padding: EdgeInsets) {
        self.font = font
        self.textColor = textColor
        self.padding = padding
    }
}

public struct BodyStyle {
    
    public var font: Font
    public var textColor: Color

    public init(font: Font, textColor: Color = Color.primary) {
        self.font = font
        self.textColor = textColor
    }
}

public struct CodeStyle {
    
    public var font: Font
    public var color: Color
    
    public init(font: Font, color: Color) {
        self.font = font
        self.color = color
    }
}

public struct CodeBlockStyle {
    
    public var font: Font
    public var background: Color
    public var cornerRadius: CGFloat
    public var formatter: ((CodeBlockElement) -> Text?)?
    
    public init(font: Font,
                background: Color = Color(.sRGB, white: 0.0, opacity: 0.05),
                cornerRadius: CGFloat = 0,
                formatter: ((CodeBlockElement) -> Text?)? = nil) {
        self.font = font
        self.background = background
        self.cornerRadius = cornerRadius
        self.formatter = formatter
    }
}

public struct BlockQuoteStyle {
    
    public var color: Color
    public var padding: CGFloat
    
    public init(color: Color, padding: CGFloat) {
        self.color = color
        self.padding = padding
    }
}

public struct ListStyle {
    
    public var font: Font
    public var textColor: Color
    public var spacing: CGFloat
    public var orderedBulletFont: Font
    public var bulletFont: Font
    
    public init(font: Font,
                textColor: Color = .primary,
                spacing: CGFloat,
                orderedBulletFont: Font,
                bulletFont: Font) {
        self.font = font
        self.textColor = textColor
        self.spacing = spacing
        self.orderedBulletFont = orderedBulletFont
        self.bulletFont = bulletFont
    }
}

public class MarkinStyle: ObservableObject {
    
    @Published public var spacing: CGFloat
    @Published public var header1: HeaderStyle
    @Published public var header2: HeaderStyle
    @Published public var header3: HeaderStyle
    @Published public var header4: HeaderStyle
    @Published public var header5: HeaderStyle
    @Published public var header6: HeaderStyle
    @Published public var body: BodyStyle
    @Published public var code: CodeStyle
    @Published public var codeBlock: CodeBlockStyle
    @Published public var blockQuote: BlockQuoteStyle
    @Published public var list: ListStyle
    
    public init(
        spacing: CGFloat = 16,
        header1: HeaderStyle = .init(font: Font.largeTitle.weight(.bold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)),
        header2: HeaderStyle = .init(font: Font.title.weight(.bold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)),
        header3: HeaderStyle = .init(font: Font.headline.weight(.semibold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)),
        header4: HeaderStyle = .init(font: Font.subheadline.weight(.semibold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)),
        header5: HeaderStyle = .init(font: Font.body.weight(.bold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)),
        header6: HeaderStyle = .init(font: Font.caption.weight(.bold),
                                     textColor: .primary,
                                     padding: EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0)),
        body: BodyStyle = .init(font: .system(size: 15), textColor: .primary),
        code: CodeStyle = .init(font: .system(size: 14, weight: .regular, design: .monospaced),
                                color: .purple),
        codeBlock: CodeBlockStyle = .init(font: .system(size: 13, weight: .regular, design: .monospaced)),
        blockQuote: BlockQuoteStyle = .init(color: .yellow, padding: 16),
        list: ListStyle = .init(font: .system(size: 15),
                                textColor: .primary,
                                spacing: 8,
                                orderedBulletFont: .system(size: 14),
                                bulletFont: .system(size: 16))
    ) {
        self.spacing = spacing
        self.header1 = header1
        self.header2 = header2
        self.header3 = header3
        self.header4 = header4
        self.header5 = header5
        self.header6 = header6
        self.body = body
        self.code = code
        self.codeBlock = codeBlock
        self.blockQuote = blockQuote
        self.list = list
    }
}
