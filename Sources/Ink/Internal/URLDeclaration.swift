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

internal enum URLDeclaration {
  // Sequential guard-based line parser.
  // swiftlint:disable cyclomatic_complexity
  /// Scan `body` for top-level `[name]: url` reference-link definitions.
  internal static func collectURLs(in body: String) -> [String: URL] {
    var urlsByName = [String: URL]()

    for rawLine in body.split(separator: "\n", omittingEmptySubsequences: false) {
      var line = rawLine
      while line.first?.isWhitespace == true { line = line.dropFirst() }

      guard line.first == "[" else { continue }
      guard let closingBracket = line.firstIndex(of: "]") else { continue }

      let afterBracket = line.index(after: closingBracket)
      guard afterBracket < line.endIndex, line[afterBracket] == ":" else { continue }

      let name = line[line.index(after: line.startIndex)..<closingBracket]
      var url = line[line.index(after: afterBracket)...]
      while url.first?.isWhitespace == true { url = url.dropFirst() }
      while url.last?.isWhitespace == true { url = url.dropLast() }

      guard !url.isEmpty else { continue }
      urlsByName[name.lowercased()] = url
    }

    return urlsByName
  }
  // swiftlint:enable cyclomatic_complexity
}
