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

extension Scanner {
    
    func peekNext(_ count: Int) -> String {
        if isAtEnd {
            return ""
        }
        let start = currentIndex
        let end = string.index(start, offsetBy: count, limitedBy: string.endIndex) ?? string.endIndex
        return String(string[start..<end])
    }
    
    func peek(_ string: String) -> Bool {
        let positionBefore = currentIndex
        defer {
            currentIndex = positionBefore
        }
        if scanString(string) != nil {
            return true
        }
        return false
    }
    
    func peekEmptyLine() -> Bool {
        let positionBefore = currentIndex
        defer {
            currentIndex = positionBefore
        }
        _ = scanWhiteSpace()
        if scanNewLine() {
            return true
        }
        return false
    }
    
    func scan(_ string: String) -> Bool {
        return scanString(string) != nil
    }
    
    func scanCharacters(in characters: String) -> String? {
        guard let output = scanCharacters(from: CharacterSet(charactersIn: characters)) else {
            return nil
        }
        return output
    }
            
    func scanUpToAndSkip(_ string: String) -> String? {
        guard let text = scanUpToString(string), scan(string) else {
            return nil
        }
        return text
    }
    
    func scanWhiteSpace() -> String? {
        return scanCharacters(in: " \t")
    }
    
    func scanNewLine() -> Bool {
        return scanString("\n") != nil
    }
    
    func scanUpToNewLine() -> String? {
        return scanUpToString("\n")
    }
    
    func skipThroughNewLine() -> Bool {
        let positionBefore = currentIndex
        _ = scanUpToNewLine()
        guard scanNewLine() else {
            currentIndex = positionBefore
            return false
        }
        return true
    }
    
    func skipWhitespaceAndThenNewLine() -> Bool {
        return skipEmptyLine()
    }
    
    func skipEmptyLine() -> Bool {
        let positionBefore = currentIndex
        _ = scanWhiteSpace()
        guard scanNewLine() else {
            currentIndex = positionBefore
            return false
        }
        return true
    }
    
    func scanText() -> String? {
        var strings: [String] = []

        while true {
            if let escapedCharacter = scanEscapedCharacter() {
                strings.append(escapedCharacter)
            } else if let string = scanUpToCharacters(from: CharacterSet(charactersIn: "\\`*_![\n")), !string.isEmpty {
                strings.append(string)
            } else if isAtImageStart() {
                // A real `![caption](url)` follows — stop and let parseImage handle it.
                break
            } else if scan("!") {
                // Bare `!` (not an image marker) — absorb into the running text run
                // so the paragraph renderer doesn't split it into a separate
                // TextElement, which would introduce a stray space when rendered
                // as HTML (e.g. "Hello world!" rendering as "Hello world !").
                strings.append("!")
            } else if isAtLinkStart() {
                // A real `[caption](url)` follows — stop and let parseLink handle it.
                break
            } else if scan("[") {
                // Bare `[` (not a link) — absorb into the running text run.
                strings.append("[")
            } else {
                break
            }
        }
        if strings.isEmpty {
            return nil
        } else {
            return strings.joined()
        }
    }

    /// Returns true if the scanner is positioned at the start of a well-formed
    /// image: `![caption](url)`. Does not advance the scanner.
    private func isAtImageStart() -> Bool {
        let position = currentIndex
        defer { currentIndex = position }
        guard scan("![") else { return false }
        guard scanUpToCharacters(from: CharacterSet(charactersIn: "]\n")) != nil else { return false }
        guard scan("](") else { return false }
        guard scanUpToCharacters(from: CharacterSet(charactersIn: ")\n")) != nil else { return false }
        return scan(")")
    }

    /// Returns true if the scanner is positioned at the start of a well-formed
    /// link: `[caption](url)`. Does not advance the scanner.
    private func isAtLinkStart() -> Bool {
        let position = currentIndex
        defer { currentIndex = position }
        guard scan("[") else { return false }
        guard scanUpToCharacters(from: CharacterSet(charactersIn: "]\n")) != nil else { return false }
        guard scan("](") else { return false }
        guard scanUpToCharacters(from: CharacterSet(charactersIn: ")\n")) != nil else { return false }
        return scan(")")
    }
    
    func scanEscapedCharacter() -> String? {
        let position = currentIndex
        if scan("\\") {
            if scan("\\") {
                return "\\"
            } else if scan("`") {
                return "`"
            } else if scan("*") {
                return "*"
            } else if scan("_") {
                return "_"
            } else if scan("{") {
                return "{"
            } else if scan("}") {
                return "}"
            } else if scan("[") {
                return "["
            } else if scan("]") {
                return "]"
            } else if scan("(") {
                return "("
            } else if scan(")") {
                return ")"
            } else if scan("#") {
                return "#"
            } else if scan("+") {
                return "+"
            } else if scan("-") {
                return "-"
            } else if scan(".") {
                return "."
            } else if scan("!") {
                return "!"
            } else {
                currentIndex = position
                return nil
            }
        }
        return nil
    }
}

