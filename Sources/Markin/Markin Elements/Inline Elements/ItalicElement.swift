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

/// Italic text is achieved by using the marker \_ as follows:
///
/// ```
/// The word *italic* is in italics in this sentence.
/// ```
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
        let element = try container.decode(InlineElement.self, forKey: .content)
        switch element.elementType {
        case "BoldElement": content = try container.decode(BoldElement.self, forKey: .content)
        case "CodeElement": content = try container.decode(CodeElement.self, forKey: .content)
        case "ImageElement": content = try container.decode(ImageElement.self, forKey: .content)
        case "ItalicElement": content = try container.decode(ItalicElement.self, forKey: .content)
        case "LinkElement": content = try container.decode(LinkElement.self, forKey: .content)
        case "TextElement": content = try container.decode(TextElement.self, forKey: .content)
        default: content = element
        }
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting

    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        let string = "_\(content.formatAsMarkin())_"
        return string
    }

    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "ITALIC(\n"
        string += content.formatDebugString(level: level + 1)
        string += indent + ")\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string = indent + "<em>\(content.formatAsHTML(document))</em>"
        return string
    }
    
    /// Render the element and its children as flat text.
    public override func formatAsText() -> String {
        return content.formatAsText()
    }
}
