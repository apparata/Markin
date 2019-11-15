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

public protocol ListEntryCompliant {}
public typealias ListEntryElement = BlockElement & ListEntryCompliant

/// Unordered list:
///
/// ```
/// - First list entry
/// - Second list entry
/// - First nested list entry
/// - Second nested list entry
/// - Third list entry
/// ```
///
/// Ordered lists:
///
/// ```
/// 1. First list entry
/// 1. Second list entry
/// 1. First nested list entry
/// 1. Second nested list entry
/// 1. Third list entry
/// ```
public class ListElement: BlockElement, ListEntryCompliant {
    
    public var isOrdered: Bool
    
    public var entries: [ListEntryElement]

    // MARK: - Initialization
    
    public init(isOrdered: Bool, entries: [ListEntryElement]) {
        self.isOrdered = isOrdered
        self.entries = entries
        super.init()
    }
    
    public enum CodingKeys: String, CodingKey {
        case isOrdered
        case entries
    }
    
    enum EntryTypeKey: String, CodingKey {
        case elementType
    }
        
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isOrdered = try container.decode(Bool.self, forKey: .isOrdered)
        var entriesArrayForType = try container.nestedUnkeyedContainer(forKey: .entries)
        var entries = [ListEntryElement]()
        
        var entriesArray = entriesArrayForType
        while !entriesArrayForType.isAtEnd {
            let entry = try entriesArrayForType.nestedContainer(keyedBy: EntryTypeKey.self)
            let type = try entry.decode(String.self, forKey: .elementType)
            switch type {
            case "ListElement": entries.append(try entriesArray.decode(ListElement.self))
            case "ParagraphElement": entries.append(try entriesArray.decode(ParagraphElement.self))
            default: break
            }
        }
        
        self.entries = entries
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isOrdered, forKey: .isOrdered)
        try container.encode(entries as [BlockElement], forKey: CodingKeys.entries)
    }
    
    // MARK: - Formatting

    /// Transform the element and its children to a Markin formatted string.
    public override func formatAsMarkin(level: Int = 0) -> String {
        var listEntries: [String] = []
        for entry in entries {
            if let paragraphEntry = entry as? ParagraphElement {
                let paragraph = formatParagraphAsMarkin(paragraphEntry, level: level)
                listEntries.append(paragraph)
            } else if let listEntry = entry as? ListElement {
                let list = listEntry.formatAsMarkin(level: level + 1)
                listEntries.append(list)
            }
        }
        var string = listEntries.joined(separator: "\n")
        if level == 0 {
            string += "\n"
        }
        return string
    }
    
    private func formatParagraphAsMarkin(_ paragraph: ParagraphElement, level: Int) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + (isOrdered ? "1. " : "- ")
        var previousElement: InlineElement?
        for element in paragraph.content {
            if previousElement is TextElement && element is TextElement {
                string += "\n"
            }
            string += element.formatAsMarkin()
            previousElement = element
        }
        return string
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public override func formatDebugString(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var string = indent + "LIST(ordered: \(isOrdered), \n"
        for entry in entries {
            string += entry.formatDebugString(level: level + 1)
        }
        string += indent + ")\n"
        return string
    }
    
    /// Render the element and its children as HTML.
    public override func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let entryIndent = indent + "  "
        var string = indent + (isOrdered ? "<ol>" : "<ul>") + "\n"
        for entry in entries {
            if let paragraphEntry = entry as? ParagraphElement {
                let paragraph = paragraphEntry.formatAsHTML(document, tag: nil)
                string += entryIndent + "<li>\(paragraph)</li>\n"
            } else if let listEntry = entry as? ListElement {
                let list = listEntry.formatAsHTML(document, level: level + 2)
                string += entryIndent + "<li>\n\(list)\(entryIndent)</li>\n"
            }
        }
        
        string += indent + (isOrdered ? "</ol>" : "</ul>") + "\n"
        return string
    }
}
