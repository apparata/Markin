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

extension String {
    
    subscript(range: PartialRangeThrough<Int>) -> String {
        let rangeStartIndex = index(startIndex, offsetBy: 0)
        let rangeEndIndex = index(startIndex, offsetBy: range.upperBound)
        let substring = self[rangeStartIndex...rangeEndIndex]
        return String(substring)
    }
    
    subscript(range: CountablePartialRangeFrom<Int>) -> String {
        let rangeStartIndex = index(startIndex, offsetBy: range.lowerBound)
        let rangeEndIndex = index(endIndex, offsetBy: -1)
        let substring = self[rangeStartIndex...rangeEndIndex]
        return String(substring)
    }
    
    subscript(range: CountableClosedRange<Int>) -> String {
        let rangeStartIndex = index(startIndex, offsetBy: range.lowerBound)
        let rangeEndIndex = index(startIndex, offsetBy: range.upperBound)
        let substring = self[rangeStartIndex...rangeEndIndex]
        return String(substring)
    }
}
