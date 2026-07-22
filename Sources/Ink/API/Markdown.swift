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

///
/// A parsed Markdown value, which contains its rendered
/// HTML representation, as well as any metadata found at
/// the top of the Markdown document.
///
/// You create instances of this type by parsing Markdown
/// strings using `MarkdownParser`.
public struct Markdown {
  /// The HTML representation of the Markdown, ready to
  /// be rendered in a web browser.
  public var html: String
  /// The inferred title of the document, from any top-level
  /// heading found when parsing. If the Markdown text contained
  /// two top-level headings, then this property will contain
  /// the first one. Note that this property does not take modifiers
  /// into acccount.
  public var title: String? {
    get { makeTitle() }
    set { overrideTitle(with: newValue) }
  }
  /// Any metadata values found at the top of the Markdown
  /// document. See this project's README for more information.
  public var metadata: [String: String]

  private let titleHeading: Heading?
  private var titleStorage = TitleStorage()

  internal init(
    html: String,
    titleHeading: Heading?,
    metadata: [String: String]
  ) {
    self.html = html
    self.titleHeading = titleHeading
    self.metadata = metadata
  }
}

extension Markdown {
  fileprivate final class TitleStorage {
    var title: String?
  }

  fileprivate mutating func overrideTitle(with title: String?) {
    let storage = TitleStorage()
    storage.title = title
    titleStorage = storage
  }

  fileprivate func makeTitle() -> String? {
    if let stored = titleStorage.title {
      return stored
    }
    titleStorage.title = titleHeading?.plainText()
    return titleStorage.title
  }
}
