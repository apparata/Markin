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

public class ItalicElement: InlineElement {
    
    public var content: InlineElement
    
    // MARK: - Initialization
    
    public init(_ content: InlineElement) {
        self.content = content
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case content
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(InlineElement.self, forKey: .content)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting

    public override func formatAsMarkin(level: Int = 0) -> String {
        let string = "_\(content.formatAsMarkin())_"
        return string
    }

    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "ITALIC(\n"
        string += content.formatDebugString(level: level + 1)
        string += indent + ")\n"
        return string
    }
}
