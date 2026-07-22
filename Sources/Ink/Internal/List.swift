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

internal struct List: Modifiable, HTMLConvertible {
  internal var modifierTarget: Modifier.Target { .lists }

  private var kind: Kind
  private var items: [Item]

  internal init(kind: Kind, renderedItems: [Item]) {
    self.kind = kind
    self.items = renderedItems
  }

  internal func html(
    usingURLs urls: NamedURLCollection,
    modifiers: ModifierCollection
  ) -> String {
    let tagName: String
    let startAttribute: String

    switch kind {
    case .unordered:
      tagName = "ul"
      startAttribute = ""
    case .ordered(let startingIndex):
      tagName = "ol"

      if startingIndex != 1 {
        startAttribute = #" start="\#(startingIndex)""#
      } else {
        startAttribute = ""
      }
    }

    let body = items.reduce(into: "") { html, item in
      html.append(item.html(usingURLs: urls, modifiers: modifiers))
    }

    return "<\(tagName)\(startAttribute)>\(body)</\(tagName)>"
  }
}

extension List {
  /// A single list item, holding its pre-rendered inner HTML (#40). The item's first
  /// paragraph is rendered "tight" (no `<p>`) and any nested lists/blocks follow.
  internal struct Item: HTMLConvertible {
    internal var renderedText: String

    internal func html(
      usingURLs urls: NamedURLCollection,
      modifiers: ModifierCollection
    ) -> String {
      "<li>\(renderedText)</li>"
    }
  }

  internal enum Kind {
    case unordered
    case ordered(firstNumber: Int)
  }
}
