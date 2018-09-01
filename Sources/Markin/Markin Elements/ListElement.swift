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

public class ListElement: BlockElement {
    
    public var isOrdered: Bool
    
    public var entries: [[InlineElement]]

    // MARK: - Initialization
    
    public init(isOrdered: Bool, entries: [[InlineElement]]) {
        self.isOrdered = true
        self.entries = entries
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case isOrdered
        case entries
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isOrdered = try container.decode(Bool.self, forKey: .isOrdered)
        entries = try container.decode([[InlineElement]].self, forKey: .entries)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isOrdered, forKey: .isOrdered)
        try container.encode(entries, forKey: .entries)
    }
    
    // MARK: - Formatting

    public override func formatAsMarkin() -> String {
        return ""
    }
    
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string = indent + "LIST(ordered: \(isOrdered)"
        return string
    }
}
