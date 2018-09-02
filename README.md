# Markin

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![license](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 4](https://img.shields.io/badge/language-Swift%204-orange.svg) ![platform iOS macOS tvOS](https://img.shields.io/badge/platform-iOS%20%7C%20tvOS%20%7C%20macOS-lightgrey.svg)

Markin is a Swift library for parsing a Markdown-like text format.

The library is small, supports Swift Package Manager, and does not have any third party dependencies.

The parser generates a tree of elements. The tree is `Codable` compliant.

The tree can also be transformed back to Markin format. This means that Markin documents can parsed, manipulated programmatically by modifying or adding the element tree, and finally written back to file.

## License

Markin is available under the MIT License. See the LICENSE file in the repository for details.

## The Markin Format

The format is based on Markdown, but I have plans to extend it. The core syntax will stay the same, however.

### Headers

Headers are available in 6 hierarchical levels:

```
# This is the largest header
## This is the second largest header
### This is the third largest header
#### This is the fourth largest header
##### This is the fifth largest header
####### This is the sixth largest header.
```

### Table of Contents

A place holder for where the table of contents should be rendered is written like this on its own separate line:

```
%TOC
```

### Text Paragraphs

A text paragraph consists of consecutive lines of text, terminated by a blank line.

```
This is the first sentence of the paragraph. This is the second sentence.
This is the third sentence, also in the paragraph.
```

### Block Quotes

A block quote is formatted as text paragraphs, but each line is prefixed with a > in the following manner:

```
> This is the first line of the block quote.
> This is the second line of the block quote.
>
> This is the first line of the second paragraph
> of the block quote.
```

### Lists

Unordered list:

```
- First list entry
- Second list entry
    - First nested list entry
    - Second nested list entry
- Third list entry
```

Ordered lists:

```
1. First list entry
1. Second list entry
    1. First nested list entry
    1. Second nested list entry
1. Third list entry
```

### Code Blocks

Code can be written in code blocks. The language can be specified after the opening ``` sequence.

<pre><code>```Swift
let a = 7
```</code></pre>

### Bold Text

Bold text is achieved by using the marker \* as follows:

```
The word *bold* is bold in this sentence.
```

Currently, bold and italic text can't be nested.

### Italic Text

Italic text is achieved by using the marker \_ as follows:

```
The word _italic_ is in italics in this sentence.
```

Currently, **bold** and _italic_ text can't be nested.

### Inline Code

Code can be written inline using single backticks \` like this:

```
This is text that has `inline code` in it.
```
