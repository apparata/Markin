import XCTest

#if !os(macOS)
public typealias XCTestCaseEntry = (testCaseClass: XCTestCase.Type, allTests: [(String, (XCTestCase) throws -> Void)])
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MarkinTests.allTests),
    ]
}
#endif
