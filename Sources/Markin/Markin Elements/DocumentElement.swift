//
// MIT License
//
// Copyright (c) 2018 Apparata AB
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public class DocumentElement: MarkinElement {
    
    public var blocks: [BlockElement]
    
    // MARK: - Initialization
    
    public init(blocks: [BlockElement]) {
        self.blocks = blocks
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case blocks
    }
    
    enum BlockTypeKey: String, CodingKey {
        case elementType
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var blocksArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.blocks)
        var blocks = [BlockElement]()

        var blocksArray = blocksArrayForType
        while !blocksArrayForType.isAtEnd {
            let block = try blocksArrayForType.nestedContainer(keyedBy: BlockTypeKey.self)
            let type = try block.decode(String.self, forKey: .elementType)
            switch type {
            case "CodeBlockElement": blocks.append(try blocksArray.decode(CodeBlockElement.self))
            case "HeaderElement": blocks.append(try blocksArray.decode(HeaderElement.self))
            case "BlockQuoteElement": blocks.append(try blocksArray.decode(BlockQuoteElement.self))
            case "ListElement": blocks.append(try blocksArray.decode(ListElement.self))
            case "HorizontalRuleElement": blocks.append(try blocksArray.decode(HorizontalRuleElement.self))
            case "ParagraphElement": blocks.append(try blocksArray.decode(ParagraphElement.self))
            default: break
            }
        }
        
        self.blocks = blocks
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blocks, forKey: .blocks)
    }
    
    // MARK: - Formatting
    
    public override func formatAsMarkin(level: Int = 0) -> String {
        var string = ""
        for block in blocks {
            string += block.formatAsMarkin()
            string += "\n"
        }
        return string
    }
    
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "BLOCKS(\n"
        for block in blocks {
            string += block.formatDebugString(level: level + 1)
        }
        string += indent + ")\n"
        return string
    }
}

