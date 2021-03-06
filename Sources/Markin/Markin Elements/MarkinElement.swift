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

/// Base element for all elements in the element tree.
public class MarkinElement: Codable {
    
    internal let elementType: String
    
    // MARK: - Initialization

    public init() {
        elementType = String(describing: type(of: self))
    }
    
    private enum ElementCodingKeys: String, CodingKey {
        case elementType
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ElementCodingKeys.self)
        elementType = try container.decode(String.self, forKey: .elementType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ElementCodingKeys.self)
        try container.encode(elementType, forKey: .elementType)
    }
    
    // MARK: - Formatting
    
    /// Transform the element and its children to a Markin formatted string.
    public func formatAsMarkin(level: Int = 0) -> String {
        return ""
    }
    
    /// Render the element and its children as a debug string. Useful when
    /// learning about the structure of the element tree.
    public func formatDebugString(level: Int = 0) -> String {
        return ""
    }

    /// Render the element and its children as HTML.
    public func formatAsHTML(_ document: DocumentElement? = nil, level: Int = 0) -> String {
        return ""
    }
}

extension MarkinElement: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: MarkinElement, rhs: MarkinElement) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
