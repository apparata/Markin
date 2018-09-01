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

public enum MarkinError: Error {
    case nonTerminatedInline(String)
    case failedToParseMarkin
    case invalidEscapedCharacter
    case failedToParseParagraph
}

public class MarkinParser {
    
    private let debugMode = false
    
    class Context {

        let markin: String
        let scanner: Scanner
        
        init(markin: String) {
            self.markin = markin
            scanner = Scanner(string: markin)
            scanner.charactersToBeSkipped = nil
        }
    }
    
    public func parse(_ markin: String) throws -> DocumentElement {
        
        let context = Context(markin: markin)
        
        let blocks = try parseBlocks(context.scanner, context)
        
        return blocks
    }
    
    func parseBlocks(_ scanner: Scanner, _ context: Context) throws -> DocumentElement {
        if debugMode { print("[parseBlocks] Enter") }
        
        var blocks: [BlockElement] = []
        
        while true {
            if scanner.skipEmptyLine() {
                // Do nothing, basically.
                print("[parseBlocks] Skipping empty line")
            } else if let block = try parseBlock(scanner, context) {
                print(block)
                blocks.append(block)
            } else if scanner.isAtEnd {
                break
            } else {
                print(scanner.peekNext(20))
                throw MarkinError.failedToParseMarkin
            }
        }
        
        return DocumentElement(blocks: blocks)
    }
    
    func parseBlock(_ scanner: Scanner, _ context: Context) throws -> BlockElement? {
        if debugMode { print("[parseBlock] Enter: " + scanner.peekNext(20) + "...") }
        
        if let header = try parseHeader(scanner, context) {
            return header
        } else if let codeBlock = parseCodeBlock(scanner, context) {
            return codeBlock
        } else if let blockQuote = parseBlockQuote(scanner, context) {
            return blockQuote
        } else if let list = parseList(scanner, context) {
            return list
        } else if let horizontalRule = parseHorizontalRule(scanner, context) {
            return horizontalRule
        } else if let paragraph = try parseParagraph(scanner, context) {
            return paragraph
        }
        
        return nil
    }
    
    func parseHeader(_ scanner: Scanner, _ context: Context) throws -> HeaderElement? {
        if debugMode { print("[parseHeader] Enter: " + scanner.peekNext(20) + "...") }
        
        let level: Int
        
        if scanner.scan("# ") {
            level = 1
        } else if scanner.scan("## ") {
            level = 2
        } else if scanner.scan("### ") {
            level = 3
        } else if scanner.scan("#### ") {
            level = 4
        } else if scanner.scan("##### ") {
            level = 5
        } else if scanner.scan("###### ") {
            level = 6
        } else {
            return nil
        }
        
        let paragraph: ParagraphElement = try parseParagraph(scanner, context) ?? ParagraphElement()
        
        return HeaderElement(level: level, content: paragraph)
    }
    
    func parseCodeBlock(_ scanner: Scanner, _ context: Context) -> CodeBlockElement? {
        if debugMode { print("[parseCodeBlock] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("```"), let language = scanner.scanUpToNewLine() else {
            return nil
        }

        guard scanner.scanNewLine() else {
            return nil
        }

        guard let code = scanner.scanUpToAndSkip("\n```") else {
            return nil
        }
        
        _ = scanner.scanUpToNewLine()

        var codeLanguage: String? = nil
        let trimmedLanguage = language.trimmingCharacters(in: .whitespaces)
        if !trimmedLanguage.isEmpty {
            codeLanguage = trimmedLanguage
        }
        
        return CodeBlockElement(language: codeLanguage, content: code)
    }

    func parseBlockQuote(_ scanner: Scanner, _ context: Context) -> BlockQuoteElement? {
        if debugMode { print("[parseBlockQuote] Enter") }
        return nil
    }

    func parseList(_ scanner: Scanner, _ context: Context) -> ListElement? {
        if debugMode { print("[parseList] Enter") }
        return nil
    }

    func parseHorizontalRule(_ scanner: Scanner, _ context: Context) -> HorizontalRuleElement? {
        if debugMode { print("[parseHorizontalRule] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        if scanner.scanUpToNewLine() == "---" {
            return HorizontalRuleElement()
        }
        scanner.scanLocation = position
        return nil
    }

    func parseParagraph(_ scanner: Scanner, _ context: Context) throws -> ParagraphElement? {
        if debugMode { print("[parseParagraph] Enter: " + scanner.peekNext(20) + "...") }
        
        var content: [InlineElement] = []
        
        while true {
            if let bold = try parseBold(scanner, context) {
                content.append(bold)
            } else if let italic = try parseItalic(scanner, context) {
                content.append(italic)
            } else if let code = try parseCode(scanner, context) {
                content.append(code)
            } else if let text = try parseText(scanner, context) {
                content.append(text)
            } else if scanner.scanNewLine() {
                if scanner.peekEmptyLine() {
                    break
                }
            } else if scanner.isAtEnd {
                break
            } else {
                throw MarkinError.failedToParseParagraph
            }
        }
        
        if content.isEmpty {
            return nil
        } else {
            return ParagraphElement(content)
        }
    }
    
    func parseBold(_ scanner: Scanner, _ context: Context) throws -> BoldElement? {
        if debugMode { print("[parseBold] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("*") else {
            return nil
        }
        
        let text = try parseText(scanner, context)
        
        guard scanner.scan("*") else {
            throw MarkinError.nonTerminatedInline("*")
        }
        
        guard let boldText = text else {
            return nil
        }
        
        return BoldElement(boldText)
    }

    func parseItalic(_ scanner: Scanner, _ context: Context) throws -> ItalicElement? {
        if debugMode { print("[parseItalic] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("_") else {
            return nil
        }
        
        let text = try parseText(scanner, context)
        
        guard scanner.scan("_") else {
            throw MarkinError.nonTerminatedInline("_")
        }
        
        guard let italicText = text else {
            return nil
        }
        
        return ItalicElement(italicText)
    }

    func parseCode(_ scanner: Scanner, _ context: Context) throws -> CodeElement? {
        
        if debugMode { print("[parseCode] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("`") else {
            return nil
        }
        
        let text = scanner.scanUpToCharacter(in: "`\n")
        
        guard scanner.scan("`") else {
            throw MarkinError.nonTerminatedInline("`")
        }
        
        guard let code = text else {
            return nil
        }
        
        return CodeElement(code)
    }
    
    func parseText(_ scanner: Scanner, _ context: Context) throws -> TextElement? {
        
        if debugMode {  print("[parseText] (\(scanner.scanLocation)) Enter: " + scanner.peekNext(20) + "...") }
        
        guard let text = try scanner.scanText() else {
            return nil
        }
        return TextElement(text)
    }
    
}
