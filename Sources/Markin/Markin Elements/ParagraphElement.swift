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

public class ParagraphElement: BlockElement, ListEntryCompliant {
    
    public var content: [InlineElement]
    
    // MARK: - Initialization
    
    public init(_ content: [InlineElement] = []) {
        self.content = content
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case content
    }
    
    enum ElementTypeKey: String, CodingKey {
        case elementType
    }
        
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var elementsArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.content)
        var elements = [InlineElement]()
        
        var elementsArray = elementsArrayForType
        while !elementsArrayForType.isAtEnd {
            let element = try elementsArrayForType.nestedContainer(keyedBy: ElementTypeKey.self)
            let type = try element.decode(String.self, forKey: .elementType)
            switch type {
            case "BoldElement": elements.append(try elementsArray.decode(BoldElement.self))
            case "ItalicElement": elements.append(try elementsArray.decode(ItalicElement.self))
            case "CodeElement": elements.append(try elementsArray.decode(CodeElement.self))
            case "TextElement": elements.append(try elementsArray.decode(TextElement.self))
            default: break
            }
        }
        
        content = elements
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
    }
    
    // MARK: - Formatting

    public override func formatAsMarkin(level: Int = 0) -> String {
        return formatAsMarkin(lineSeparator: "\n")
    }
    
    public func formatAsMarkin(lineSeparator: String) -> String {
        var string = ""
        var previousElement: InlineElement?
        for element in content {
            if previousElement is TextElement && element is TextElement {
                string += lineSeparator
            }
            string += element.formatAsMarkin()
            previousElement = element
        }
        string += "\n"
        return string
    }

    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "PARAGRAPH(\n"
        for element in content {
            string += element.formatDebugString(level: level + 1)
        }
        string += indent + ")\n"
        return string
    }
    
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        return formatAsHTML(document, level: level, tag: "p")
    }
    
    func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0, tag: String?) -> String {
        let indent = String(repeating: "  ", count: level)
        let tagIndent = indent + (tag == nil ? "" : "  ")
        var string = indent
        if let tag = tag {
            string += "<\(tag)>\n" + tagIndent
        }
        var previousElement: InlineElement?
        for element in content {
            if previousElement is TextElement && element is TextElement {
                string += "\n" + tagIndent
            }
            string += element.formatAsHTML(document)
            previousElement = element
        }
        if let tag = tag {
            string += "\n\(indent)</\(tag)>\n"
        }
        return string
    }
    
    public func formatAsText() -> String {
        var string = ""
        var previousElement: InlineElement?
        for element in content {
            if previousElement is TextElement && element is TextElement {
                string += "\n"
            }
            string += element.formatAsText()
            previousElement = element
        }
        return string
    }
}
