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

/// A placeholder for where the table of contents should be rendered is written
/// like this on its own separate line:
///
/// ```
/// %TOC
/// ```
///
/// The table of contents must be generated when rendering the table of
/// contents, as this element merely points out _where_ the table of contents
/// should be rendered.
public class TableOfContentsElement: BlockElement {
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    // MARK: - Formatting
    
    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        return "%TOC\n"
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let string = indent + "TOC()\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let headers = document?.blocks.compactMap { $0 as? HeaderElement} ?? []
        guard !headers.isEmpty else {
            return ""
        }
        let html = makeHeaderListHTML(headers, level: level)
        let string = indent + "\(html)"
        return string
    }
    
    private func makeHeaderListHTML(_ headers: [HeaderElement], level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var listIndent = indent
        var entryIndent = indent + "  "
        var string = indent + "<ul class=\"tableOfContents\">\n"
        var listLevel = 1
        var currentHeaderLevel = 1
        for header in headers {
            
            if header.level > currentHeaderLevel {
                listLevel += 1
                listIndent = indent + String(repeating: "  ", count: (listLevel - 1) * 2)
                string += entryIndent + "<li>\n\(listIndent)<ul>\n"
                entryIndent = listIndent + "  "
            } else if header.level < currentHeaderLevel {
                listLevel -= 1
                string += "\(listIndent)</ul>\n"
                listIndent = indent + String(repeating: "  ", count: (listLevel - 1) * 2)
                entryIndent = listIndent + "  "
                string += "\(entryIndent)</li>\n"
            }
            currentHeaderLevel = header.level
            
            let headerText = header.content.formatAsHTML(nil, tag: nil)
            let anchorID = header.formatAsAnchorID()
            string += entryIndent + "<li><a href=\"#\(anchorID)\">\(headerText)</a></li>\n"
        }
        
        while listLevel > 1 {
            string += "\(listIndent)</ul>\n"
            listIndent = indent + String(repeating: "  ", count: (listLevel - 1) * 2)
            entryIndent = indent + String(repeating: "  ", count: (listLevel - 1) * 2 - 1)
            string += "\(entryIndent)</li>\n"
            listLevel -= 1
        }
        
        string += indent + "</ul>\n"
        return string
    }
}
