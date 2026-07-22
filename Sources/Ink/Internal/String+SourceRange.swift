/**
 *  Ink
 *
 *  Copyright (c) 2019 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

extension String {
  // Inherently branchy: line/column scan.
  // swiftlint:disable cyclomatic_complexity
  /// Resolve a 1-based line / 1-based UTF-8-byte column pair (swift-markdown's
  /// `SourceLocation` convention) to a `String.Index`, or `nil` if out of bounds.
  internal func lineColumnIndex(line: Int, column: Int) -> String.Index? {
    guard line >= 1, column >= 1 else {
      return nil
    }

    // Advance to the start of the requested line by counting newlines.
    var currentLine = 1
    var lineStart = startIndex
    if line > 1 {
      var index = startIndex
      while index < endIndex {
        if self[index] == "\n" {
          currentLine += 1
          if currentLine == line {
            lineStart = self.index(after: index)
            break
          }
        }
        index = self.index(after: index)
      }
      guard currentLine == line else {
        return nil
      }
    }

    // Column is a UTF-8 byte offset from the start of the line.
    let byteOffset = column - 1
    let utf8 = self.utf8
    guard let utf8LineStart = lineStart.samePosition(in: utf8) else {
      return nil
    }
    guard
      let utf8Index = utf8.index(
        utf8LineStart,
        offsetBy: byteOffset,
        limitedBy: utf8.endIndex
      )
    else {
      return nil
    }
    return utf8Index.samePosition(in: self)
  }
  // swiftlint:enable cyclomatic_complexity
}
