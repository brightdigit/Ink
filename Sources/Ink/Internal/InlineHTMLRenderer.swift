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

import Markdown

/// Converts swift-markdown inline markup into Ink-compatible HTML.
internal struct InlineHTMLRenderer {
  private let urls: NamedURLCollection

  internal init(urls: NamedURLCollection) {
    self.urls = urls
  }

  // Inherently branchy: one case per swift-markdown inline type.
  // swiftlint:disable:next cyclomatic_complexity
  internal mutating func render(_ inline: InlineMarkup) -> String {
    switch inline {
    case let text as Text:
      return HTMLEscaping.escape(text.string)
    case let emphasis as Emphasis:
      return wrap("em", emphasis.inlineChildren)
    case let strong as Strong:
      return wrap("strong", strong.inlineChildren)
    case let strikethrough as Strikethrough:
      return wrap("s", strikethrough.inlineChildren)
    case let code as Markdown::InlineCode:
      return "<code>\(HTMLEscaping.escape(code.code))</code>"
    case let link as Markdown::Link:
      return renderLink(link)
    case let image as Markdown::Image:
      return renderImage(image)
    case is LineBreak:
      return "<br>"
    case is SoftBreak:
      // Ink joins soft-wrapped lines with a single space.
      return " "
    case let html as InlineHTML:
      return html.rawHTML
    default:
      return HTMLEscaping.escape(inline.plainText)
    }
  }

  private mutating func renderChildren<S: Sequence>(_ inlines: S) -> String
  where S.Element == InlineMarkup {
    inlines.reduce(into: "") { $0.append(render($1)) }
  }

  private mutating func wrap<S: Sequence>(_ tag: String, _ inlines: S) -> String
  where S.Element == InlineMarkup {
    "<\(tag)>\(renderChildren(inlines))</\(tag)>"
  }

  private mutating func renderLink(_ link: Markdown::Link) -> String {
    let destination = resolve(destination: link.destination, fallbackText: link.plainText)
    let title = renderChildren(link.inlineChildren)
    return "<a href=\"\(destination)\">\(title)</a>"
  }

  private mutating func renderImage(_ image: Markdown::Image) -> String {
    let source = resolve(destination: image.source, fallbackText: image.plainText)
    var alt = renderChildren(image.inlineChildren)
    if !alt.isEmpty {
      alt = " alt=\"\(alt)\""
    }
    return "<img src=\"\(source)\"\(alt)/>"
  }

  /// Resolve a link/image destination: swift-markdown leaves the destination `nil`
  /// for unresolved reference-style links, so fall back to the retained Ink reference
  /// table keyed on the link text (mirroring Ink's `Link.Target.reference`).
  private func resolve(destination: String?, fallbackText: String) -> String {
    if let destination, !destination.isEmpty {
      return destination
    }
    if let referenced = urls.url(named: Substring(fallbackText)) {
      return String(referenced)
    }
    return fallbackText
  }
}
