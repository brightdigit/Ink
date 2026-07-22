/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
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
