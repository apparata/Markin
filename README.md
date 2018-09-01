# Markin

 [![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) ![license](https://img.shields.io/badge/license-MIT-blue.svg) ![language Swift 4](https://img.shields.io/badge/language-Swift%204-orange.svg) ![platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg) ![platform iOS](https://img.shields.io/badge/platform-iOS-lightgrey.svg) ![platform tvOS](https://img.shields.io/badge/platform-tvOS-lightgrey.svg)

Markin is a Swift library for parsing a Markdown-like text format.

The library is small, supports Swift Package Manager, and does not have any third party dependencies.

Trivia: It's called Markin because I was inspired by Linus Torvalds in naming my creation after myself, but replacing one of the letters in the name.

## License

Markin is available under the MIT License. See the LICENSE file in the repository for details.

## The Markin Format

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

### Code Blocks

Code can be written in code blocks. The language can be specified after the opening ``` sequence.

<pre><code>```Swift
let a = 7
```</code></pre>

### Text Paragraphs

A text paragraph consists of consecutive lines of text, terminated by a blank line.

```
This is the first sentence of the paragraph. This is the second sentence.
This is the third sentence, also in the paragraph.
```

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
