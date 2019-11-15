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

/// Code can be written in code blocks. The language can be specified after the
/// opening ``` sequence. Since the
///
/// ```
/// ```Swift
/// let a = 7
/// ```                                                                    //
/// ```
public class CodeBlockElement: BlockElement {
    
    public var language: String?
    
    public var content: String
    
    // MARK: - Initialization
    
    public init(language: String?, content: String) {
        self.language = language
        self.content = content
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case language
        case content
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        content = try container.decode(String.self, forKey: .content)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting

    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        var string = "```\(language ?? "")\n"
        string += content
        string += "\n```\n"
        return string
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "CODEBLOCK(language: \(language ?? "N/A"),\n"
        string += content + "\n"
        string += indent + ")\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string: String
        let code = content.htmlEntityEncoded()
        if let language = language {
            string = indent + "<pre><code class=\"\(language)\">\(code)</code></pre>\n"
        } else {
            string = indent + "<pre><code>\(code)</code></pre>\n"
        }
        return string
    }
}
