import XCTest
@testable import Markin

final class MarkinTests: XCTestCase {

    func testExample() {
        let exampleMarkin = """

%TOC

# Swift Package Manager Cheat Sheet

## Banana

This is a cheat sheet for some common `Swift package manager` operations.

Another paragraph.
This one on 2 lines.

[a link](https://google.com)

Here's [a link](https://google.com) inline.

Here's ![an image](/banana.jpg) inline.

### Blockquote

> This right here is a block quote.
> Second line of the quote.
>
> Fourth line of the quote.

## Unordered List

- First item in unordered list
- Second item in unordered list
    - First item in nested list
    - Second item in nested list
- Fourth item in unordered list

## Ordered List

1. First item in *ordered* list
1. Second item in ordered list
1. Third item in ordered list

# Executable Package

Create executable package:

```bash
swift package init --type executable
```

---

### Library

Create *library* package:

```bash
swift package init --type library
```

HTML test:

```
<b>This is bold HTML</b>
```

This is the last paragraph.
"""
        
        let parser = MarkinParser()
        
        do {
            let document = try parser.parse(exampleMarkin)
            print(document.formatDebugString())
            print(document.formatAsMarkin())
            print(document.formatAsHTML())
            let jsonData = try JSONEncoder().encode(document)
            print(String(data: jsonData, encoding: .utf8)!)
            let decodedDocument = try JSONDecoder().decode(DocumentElement.self, from: jsonData)
            print(decodedDocument.formatDebugString())
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
