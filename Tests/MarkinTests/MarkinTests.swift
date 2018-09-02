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

> This right here is a block quote.
> Second line of the quote.
>
> Fourth line of the quote.

- First item in unordered list
- Second item in unordered list
    - First item in nested list
    - Second item in nested list
- Fourth item in unordered list

1. First item in *ordered* list
1. Second item in ordered list
1. Third item in ordered list

Create executable package:

```bash
swift package init --type executable
```

---

Create *library* package:

```bash
swift package init --type library
```
"""
        let parser = MarkinParser()
        
        do {
            let result = try parser.parse(exampleMarkin)
            print(result.formatDebugString())
            print(result.formatAsMarkin())
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }

    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
