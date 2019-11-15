//
// MIT License
//
// Copyright (c) 2019 Apparata AB
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

/// Image references can be written on the form ![caption](url) like this:
///
/// ```
/// This is text that has ![an image](https://apparata.se/image.png) in it.
/// ```
public class ImageElement: InlineElement {
    
    public var url: String
    
    /// The caption of the link.
    public var content: String
    
    // MARK: - Initialization
    
    public init(_ content: String, _ url: String) {
        self.content = content
        self.url = url
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case url
        case content
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        content = try container.decode(String.self, forKey: .content)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting
    
    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        return "`" + content + "`"
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string = indent + "IMAGE(url: \(url), \(content))\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string = indent + "<img src=\"\(url)\" alt=\"\(content.htmlEntityEncoded())\">"
        return string
    }
    
    /// Render the element and its children as flat text.
    public override func formatAsText() -> String {
        return content
    }
}
