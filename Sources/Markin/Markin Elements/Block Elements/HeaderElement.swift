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

/// Headers are available in 6 hierarchical levels:
///
/// ```
/// # This is the largest header
/// ## This is the second largest header
/// ### This is the third largest header
/// #### This is the fourth largest header
/// ##### This is the fifth largest header
/// ####### This is the sixth largest header.
/// ```
public class HeaderElement: BlockElement {
    
    /// The level of the header (1 - 6)
    public var level: Int
    
    /// The textual content of the header.
    public var content: ParagraphElement
    
    // MARK: - Initialization

    public init(level: Int, content: ParagraphElement) {
        self.level = level
        self.content = content
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case level
        case content
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decode(Int.self, forKey: .level)
        content = try container.decode(ParagraphElement.self, forKey: .content)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting

    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        var string = String(repeating: "#", count: self.level) + " "
        string += content.formatAsMarkin()
        return string
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "HEADER(level: \(self.level),\n"
        string += content.formatDebugString(level: level + 1)
        string += indent + ")\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let contentHTML = content.formatAsHTML(document, tag: nil)
        let anchor = "<a id=\"\(formatAsAnchorID())\"> </a>"
        let string = indent + "<h\(self.level)>\(anchor)\(contentHTML)</h\(self.level)>\n"
        return string
    }
    
    /// Format a string that is suitable for use as an HTML anchor or other
    /// string that identifies this particular header.
    public func formatAsAnchorID() -> String {
        let contentHTML = content.formatAsHTML(nil, tag: nil)
        let noTagsString = contentHTML.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        let chars: [Character] = noTagsString.lowercased().map { char in
            if "abcdefghijklmnopqrstuvwxyz0123456789".contains(char) {
                return char
            } else {
                return Character("-")
            }
        }
        let id = String(chars)
        return id
    }
    
}

