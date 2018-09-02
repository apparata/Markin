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

public class MarkinParser {
    
    private let debugMode = true
    
    private class Context {

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
    
    private func parseBlocks(_ scanner: Scanner, _ context: Context) throws -> DocumentElement {
        if debugMode { print("[parseBlocks] Enter") }
        
        var blocks: [BlockElement] = []
        
        while true {
            if scanner.skipEmptyLine() {
                // Do nothing, basically.
                if debugMode { print("[parseBlocks] Skipping empty line") }
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
    
    private func parseBlock(_ scanner: Scanner, _ context: Context) throws -> BlockElement? {
        if debugMode { print("[parseBlock] Enter: " + scanner.peekNext(20) + "...") }
        
        if let tableOfContents = try parseTableOfContents(scanner, context) {
            return tableOfContents
        } else if let header = try parseHeader(scanner, context) {
            return header
        } else if let codeBlock = parseCodeBlock(scanner, context) {
            return codeBlock
        } else if let blockQuote = parseBlockQuote(scanner, context) {
            return blockQuote
        } else if let list = parseList(scanner, context) {
            return list
        } else if let horizontalRule = parseHorizontalRule(scanner, context) {
            return horizontalRule
        } else if let paragraph = parseParagraph(scanner, context) {
            return paragraph
        }
        
        return nil
    }
    
    private func parseTableOfContents(_ scanner: Scanner, _ context: Context) throws -> TableOfContentsElement? {
        if debugMode { print("[parseTableOfContents] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("%TOC") else {
            return nil
        }
        
        guard scanner.skipWhitespaceAndThenNewLine() else {
            return nil
        }
        
        return TableOfContentsElement()
    }
    
    private func parseHeader(_ scanner: Scanner, _ context: Context) throws -> HeaderElement? {
        if debugMode { print("[parseHeader] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
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
        
        guard let paragraph = parseParagraph(scanner, context) else {
            scanner.scanLocation = position
            return nil
        }

        return HeaderElement(level: level, content: paragraph)
    }
    
    private func parseCodeBlock(_ scanner: Scanner, _ context: Context) -> CodeBlockElement? {
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
        
        _ = scanner.skipThroughNewLine()

        var codeLanguage: String? = nil
        let trimmedLanguage = language.trimmingCharacters(in: .whitespaces)
        if !trimmedLanguage.isEmpty {
            codeLanguage = trimmedLanguage
        }
        
        return CodeBlockElement(language: codeLanguage, content: code)
    }
    
    private func parseBlockQuote(_ scanner: Scanner, _ context: Context) -> BlockQuoteElement? {
        if debugMode { print("[parseBlockQuote] Enter: " + scanner.peekNext(20) + "...") }
        
        var content: [ParagraphElement] = []
        
        let position = scanner.scanLocation
        
        guard scanner.scan(">") else {
            return nil
        }
        
        _ = scanner.scanWhiteSpace()
        
        while true {
            guard let paragraph = parseParagraph(scanner, context, linePrefix: ">") else {
                break
            }
            content.append(paragraph)
        }
        
        if content.isEmpty {
            scanner.scanLocation = position
            return nil
        } else {
            return BlockQuoteElement(content)
        }
    }

    
    private func parseList(_ scanner: Scanner, _ context: Context) -> ListElement? {
        if debugMode { print("[parseList] Enter") }
        return nil
    }

    private func parseHorizontalRule(_ scanner: Scanner, _ context: Context) -> HorizontalRuleElement? {
        if debugMode { print("[parseHorizontalRule] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        if scanner.scanUpToNewLine() == "---" {
            _ = scanner.scanNewLine()
            return HorizontalRuleElement()
        }
        scanner.scanLocation = position
        return nil
    }

    private func parseParagraph(_ scanner: Scanner, _ context: Context, linePrefix: String? = nil) -> ParagraphElement? {
        if debugMode { print("[parseParagraph] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        var content: [InlineElement] = []
        
        while true {
            if let bold = parseBold(scanner, context) {
                content.append(bold)
            } else if let italic = parseItalic(scanner, context) {
                content.append(italic)
            } else if let code = parseCode(scanner, context) {
                content.append(code)
            } else if let text = parseText(scanner, context) {
                content.append(text)
            } else if scanner.scanNewLine() {
                if let linePrefix = linePrefix {
                    if scanner.scan(linePrefix) {
                        // Scan to first non-whitespace character on line.
                        _ = scanner.scanWhiteSpace()
                    } else {
                        guard scanner.peekEmptyLine() else {
                            scanner.scanLocation = position
                            return nil
                        }
                    }
                }
                if scanner.peekEmptyLine() {
                    break
                }
            } else if scanner.isAtEnd {
                break
            } else {
                scanner.scanLocation = position
                return nil
            }
        }
        
        if content.isEmpty {
            scanner.scanLocation = position
            return nil
        } else {
            return ParagraphElement(content)
        }
    }
    
    private func parseBold(_ scanner: Scanner, _ context: Context) -> BoldElement? {
        if debugMode { print("[parseBold] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        guard scanner.scan("*") else {
            return nil
        }
        
        let text = parseText(scanner, context)
        
        guard scanner.scan("*") else {
            scanner.scanLocation = position
            return nil
        }
        
        guard let boldText = text else {
            scanner.scanLocation = position
            return nil
        }
        
        return BoldElement(boldText)
    }

    private func parseItalic(_ scanner: Scanner, _ context: Context) -> ItalicElement? {
        if debugMode { print("[parseItalic] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        guard scanner.scan("_") else {
            return nil
        }
        
        let text = parseText(scanner, context)
        
        guard scanner.scan("_") else {
            scanner.scanLocation = position
            return nil
        }
        
        guard let italicText = text else {
            scanner.scanLocation = position
            return nil
        }
        
        return ItalicElement(italicText)
    }

    private func parseCode(_ scanner: Scanner, _ context: Context) -> CodeElement? {
        if debugMode { print("[parseCode] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation

        guard scanner.scan("`") else {
            return nil
        }
        
        let text = scanner.scanUpToCharacter(in: "`\n")
        
        guard scanner.scan("`") else {
            scanner.scanLocation = position
            return nil
        }
        
        guard let code = text else {
            scanner.scanLocation = position
            return nil
        }
        
        return CodeElement(code)
    }
    
    private func parseText(_ scanner: Scanner, _ context: Context) -> TextElement? {
        
        if debugMode {  print("[parseText] (\(scanner.scanLocation)) Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        guard let text = scanner.scanText() else {
            scanner.scanLocation = position
            return nil
        }
        return TextElement(text)
    }
    
}
