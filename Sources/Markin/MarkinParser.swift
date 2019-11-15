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

// MARK: - Markin Parser

/// The `MarkinParser` parses Markin formatted text strings. The result is
/// a tree of element objects with `DocumentElement` as its root.
public class MarkinParser {

    private let debugMode = false

    // MARK: - Parse Mode
    
    public enum ParseMode {
        case markin
        case markdownCompatibility
    }
    
    public let mode: ParseMode
        
    // MARK: - Context
    
    private class Context {
        
        let markin: String
        let mode: ParseMode
        let scanner: Scanner
        
        init(markin: String, mode: ParseMode) {
            self.markin = markin
            self.mode = mode
            scanner = Scanner(string: markin)
            scanner.charactersToBeSkipped = nil
        }
    }
    
    // MARK: - Initializer
    
    public init(mode: ParseMode = .markin) {
        self.mode = mode
    }
    
    // MARK: - Parse
    
    /// Parses Markin formatted text strings. The result is
    /// a tree of element objects with `DocumentElement` as its root.
    ///
    /// - parameter markin: Markin formatted string.
    /// - returns: A `DocumentElement` as the root of an element tree
    ///            representing the Markin string.
    public func parse(_ markin: String) throws -> DocumentElement {
        
        let context = Context(markin: markin + "\n", mode: mode)
        
        let blocks = try parseBlocks(context.scanner, context)
        
        return blocks
    }
    
    // MARK: - Parse Blocks
    
    private func parseBlocks(_ scanner: Scanner, _ context: Context) throws -> DocumentElement {
        if debugMode { print("[parseBlocks] Enter") }
        
        var blocks: [BlockElement] = []
        
        while true {
            if scanner.skipEmptyLine() {
                // Do nothing, basically.
                if debugMode { print("[parseBlocks] Skipping empty line") }
            } else if let block = try parseBlock(scanner, context) {
                blocks.append(block)
            } else if scanner.isAtEnd {
                break
            } else {
                if debugMode { print(scanner.peekNext(20)) }
                throw MarkinError.failedToParseMarkin
            }
        }
        
        return DocumentElement(blocks: blocks)
    }
    
    // MARK: - Parse Block
    
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
    
    // MARK: - Parse Table of Contents
    
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
    
    // MARK: - Parse Header
    
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
    
    // MARK: - Parse Code Block
    
    private func parseCodeBlock(_ scanner: Scanner, _ context: Context) -> CodeBlockElement? {
        if debugMode { print("[parseCodeBlock] Enter: " + scanner.peekNext(20) + "...") }
        
        guard scanner.scan("```") else {
            return nil
        }
        
        let language = scanner.scanUpToNewLine()
        
        guard scanner.scanNewLine() else {
            return nil
        }
        
        guard let code = scanner.scanUpToAndSkip("\n```") else {
            return nil
        }
        
        _ = scanner.skipThroughNewLine()
        
        var codeLanguage: String? = nil
        if let trimmedLanguage = language?.trimmingCharacters(in: .whitespaces) {
            if !trimmedLanguage.isEmpty {
                codeLanguage = trimmedLanguage
            }
        }
        
        return CodeBlockElement(language: codeLanguage, content: code)
    }
    
    // MARK: - Parse Block Quote
    
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
    
    // MARK: - Parse List
    
    private func parseList(_ scanner: Scanner, _ context: Context, listLevel: Int? = nil) -> ListElement? {
        if debugMode { print("[parseList] Enter: " + scanner.peekNext(20) + "...") }
        
        var isOrdered = false
        
        var entries: [ListEntryElement] = []
        
        let position = scanner.scanLocation
        
        var currentLevel: Int? = listLevel
        
        while true {
            
            let positionBeforeLevelCheck = scanner.scanLocation
            
            var level: Int = 0
            if let whiteSpace = scanner.scanWhiteSpace() {
                let onlySpaces = whiteSpace.replacingOccurrences(of: "\t", with: "  ")
                level = onlySpaces.count / 2
            }
            
            if scanner.scan("- ") {
                isOrdered = false
            } else if scanner.scan("1. ") {
                isOrdered = true
            } else {
                scanner.scanLocation = position
                return nil
            }
            
            scanner.scanLocation = positionBeforeLevelCheck
            
            if let currentLevel = currentLevel, level < currentLevel {
                // This list nesting level ended.
                break
            } else if let currentLevel = currentLevel, level > currentLevel {
                guard let entry = parseList(scanner, context, listLevel: level) else {
                    scanner.scanLocation = position
                    return nil
                }
                entries.append(entry)
                // Restore level
                level = currentLevel
                if scanner.peekEmptyLine() || scanner.isAtEnd {
                    break
                }
            } else {
                guard let entry = parseListEntry(scanner, context) else {
                    scanner.scanLocation = position
                    return nil
                }
                
                entries.append(entry)
                
                if scanner.peekEmptyLine() || scanner.isAtEnd {
                    break
                }
            }
            
            currentLevel = level
        }
        
        if entries.isEmpty {
            scanner.scanLocation = position
            return nil
        } else {
            return ListElement(isOrdered: isOrdered, entries: entries)
        }
    }
    
    // MARK: - Parse List Entry
    
    private func parseListEntry(_ scanner: Scanner, _ context: Context) -> ListEntryElement? {
        if debugMode { print("[parseListEntry] Enter: " + scanner.peekNext(20) + "...") }
        
        var content: [InlineElement] = []
        
        let positionBeforeLevelCheck = scanner.scanLocation
        _ = scanner.scanWhiteSpace()
        guard scanner.scan("- ") || scanner.scan("1. ") else {
            scanner.scanLocation = positionBeforeLevelCheck
            return nil
        }
        
        while true {
            if let bold = parseBold(scanner, context) {
                content.append(bold)
            } else if let italic = parseItalic(scanner, context) {
                content.append(italic)
            } else if let image = parseImage(scanner, context) {
                content.append(image)
            } else if let link = parseLink(scanner, context) {
                content.append(link)
            } else if let code = parseCode(scanner, context) {
                content.append(code)
            } else if let text = parseText(scanner, context) {
                content.append(text)
            } else if scanner.scanNewLine() {
                let positionBeforeLevelCheck = scanner.scanLocation
                _ = scanner.scanWhiteSpace()
                if scanner.scan("- ") || scanner.scan("1. ") {
                    scanner.scanLocation = positionBeforeLevelCheck
                    break
                }
                if scanner.peekEmptyLine() || scanner.isAtEnd {
                    break
                }
            } else if scanner.isAtEnd {
                break
            } else {
                return nil
            }
        }
        
        let paragraph = ParagraphElement(content)
        return paragraph
    }
    
    // MARK: - Parse Horizontal Rule
    
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
    
    // MARK: - Parse Paragraph
    
    private func parseParagraph(_ scanner: Scanner, _ context: Context, linePrefix: String? = nil) -> ParagraphElement? {
        if debugMode { print("[parseParagraph] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        var content: [InlineElement] = []
        
        while true {
            if let bold = parseBold(scanner, context) {
                content.append(bold)
            } else if let italic = parseItalic(scanner, context) {
                content.append(italic)
            } else if let image = parseImage(scanner, context) {
                content.append(image)
            } else if let link = parseLink(scanner, context) {
                content.append(link)
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
    
    // MARK: - Parse Bold
    
    private func parseBold(_ scanner: Scanner, _ context: Context) -> BoldElement? {
        if debugMode { print("[parseBold] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        switch context.mode {
        case .markin:
            guard scanner.scan("*") else {
                return nil
            }
        case .markdownCompatibility:
            guard scanner.scan("**") || scanner.scan("__") else {
                return nil
            }
        }
        
        let text = parseText(scanner, context)

        switch context.mode {
        case .markin:
            guard scanner.scan("*") else {
                scanner.scanLocation = position
                return nil
            }
        case .markdownCompatibility:
            guard scanner.scan("**") || scanner.scan("__") else {
                scanner.scanLocation = position
                return nil
            }
        }
        
        guard let boldText = text else {
            scanner.scanLocation = position
            return nil
        }
        
        return BoldElement(boldText)
    }
    
    // MARK: - Parse Italic
    
    private func parseItalic(_ scanner: Scanner, _ context: Context) -> ItalicElement? {
        if debugMode { print("[parseItalic] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        switch context.mode {
        case .markin:
            guard scanner.scan("_") else {
                return nil
            }
        case .markdownCompatibility:
            guard scanner.scan("*") || scanner.scan("_") else {
                return nil
            }
        }
        
        let text = parseText(scanner, context)

        switch context.mode {
        case .markin:
            guard scanner.scan("_") else {
                scanner.scanLocation = position
                return nil
            }
        case .markdownCompatibility:
            guard scanner.scan("*") || scanner.scan("_") else {
                scanner.scanLocation = position
                return nil
            }
        }
        
        guard let italicText = text else {
            scanner.scanLocation = position
            return nil
        }
        
        return ItalicElement(italicText)
    }
    
    // MARK: - Parse Image
    
    private func parseImage(_ scanner: Scanner, _ context: Context) -> ImageElement? {
        if debugMode { print("[parseImage] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        guard scanner.scan("![") else {
            return nil
        }
        
        let captionText = scanner.scanUpToCharacter(in: "]\n")
        
        guard scanner.scan("](") else {
            scanner.scanLocation = position
            return nil
        }
        
        let urlText = scanner.scanUpToCharacter(in: ")\n")
        
        guard scanner.scan(")") else {
            scanner.scanLocation = position
            return nil
        }
        
        guard let caption = captionText, let url = urlText else {
            scanner.scanLocation = position
            return nil
        }
        
        return ImageElement(caption, url)
    }
    
    // MARK: - Parse Link
    
    private func parseLink(_ scanner: Scanner, _ context: Context) -> LinkElement? {
        if debugMode { print("[parseLink] Enter: " + scanner.peekNext(20) + "...") }
        
        let position = scanner.scanLocation
        
        guard scanner.scan("[") else {
            return nil
        }
        
        let captionText = scanner.scanUpToCharacter(in: "]\n")
        
        guard scanner.scan("](") else {
            scanner.scanLocation = position
            return nil
        }
        
        let urlText = scanner.scanUpToCharacter(in: ")\n")
        
        guard scanner.scan(")") else {
            scanner.scanLocation = position
            return nil
        }
        
        guard let caption = captionText, let url = urlText else {
            scanner.scanLocation = position
            return nil
        }
        
        return LinkElement(caption, url)
    }
    
    // MARK: - Parse Code
    
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
    
    // MARK: - Parse Text
    
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
