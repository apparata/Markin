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
        let start = scanLocation
        let end = min(start + count, string.count)
        return string[start...end - 1]
    }
    
    func peek(_ string: String) -> Bool {
        let positionBefore = scanLocation
        defer {
            scanLocation = positionBefore
        }
        if scanString(string, into: nil) {
            return true
        }
        return false
    }
    
    func peekEmptyLine() -> Bool {
        let positionBefore = scanLocation
        defer {
            scanLocation = positionBefore
        }
        _ = scanWhiteSpace()
        if scanNewLine() {
            return true
        }
        return false
    }
    
    func scan(_ string: String) -> Bool {
        return scanString(string, into: nil)
    }
    
    func scanCharacters(in characters: String) -> String? {
        var output: NSString? = nil
        guard scanCharacters(from: CharacterSet(charactersIn: characters), into: &output) else {
            return nil
        }
        return output as String?
    }
    
    func scanUpTo(_ string: String) -> String? {
        var output: NSString? = nil
        guard scanUpTo(string, into: &output) else {
            return nil
        }
        return output as String?
    }
    
    func scanUpToCharacter(in characters: String) -> String? {
        var output: NSString? = nil
        guard scanUpToCharacters(from: CharacterSet(charactersIn: characters), into: &output) else {
            return nil
        }
        return output as String?
    }
    
    func scanUpToAndSkip(_ string: String) -> String? {
        guard let text = scanUpTo(string), scan(string) else {
            return nil
        }
        return text
    }
    
    func scanWhiteSpace() -> String? {
        return scanCharacters(in: " \t")
    }
    
    func scanNewLine() -> Bool {
        return scanString("\n", into: nil)
    }
    
    func scanUpToNewLine() -> String? {
        return scanUpTo("\n")
    }
        
    func skipThroughNewLine() -> Bool {
        let positionBefore = scanLocation
        _ = scanUpToNewLine()
        guard scanNewLine() else {
            scanLocation = positionBefore
            return false
        }
        return true
    }
    
    func skipWhitespaceAndThenNewLine() -> Bool {
        return skipEmptyLine()
    }
    
    func skipEmptyLine() -> Bool {
        let positionBefore = scanLocation
        _ = scanWhiteSpace()
        guard scanNewLine() else {
            scanLocation = positionBefore
            return false
        }
        return true
    }
    
    func scanText() -> String? {
        var strings: [String] = []
        while true {
            if let escapedCharacter = scanEscapedCharacter() {
                strings.append(escapedCharacter)
            } else if let string = scanUpToCharacter(in: "\\`*_\n"), !string.isEmpty {
                strings.append(string)
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
    
    func scanEscapedCharacter() -> String? {
        let position = scanLocation
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
                scanLocation = position
                return nil
            }
        }
        return nil
    }
}

