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
/// Modifiers can be attached to a `MarkdownParser` and are used
/// to customize Ink's parsing process. Each modifier is associated
/// with a given `Target`, which determines which type of Markdown
/// fragments that it is capable of modifying.
///
/// You can use a `Modifier` to adjust the HTML that was generated
/// for a given fragment, or to inject completely custom HTML based
/// on the fragment's raw Markdown representation.
public struct Modifier: Sendable {
  /// The type of input that each modifier is given, which both
  /// contains the HTML that was generated for a fragment, and
  /// its raw Markdown representation. Note that for metadata
  /// targets, the two input arguments will be equivalent.
  public typealias Input = (html: String, markdown: Substring)
  /// The type of closure that Modifiers are based on. Each
  /// modifier is given a set of input, and is expected to return
  /// an HTML string after performing its modifications.
  public typealias Closure = @Sendable (Input) -> String

  /// The modifier's target, that defines what kind of fragment
  /// that it's used to modify. See `Target` for more info.
  public var target: Target
  /// The closure that makes up the modifier's body.
  public var closure: Closure

  /// Initialize an instance with the kind of target that the modifier
  /// should be used on, and a closure that makes up its body.
  public init(target: Target, closure: @escaping Closure) {
    self.target = target
    self.closure = closure
  }
}

extension Modifier {
  /// The kind of Markdown fragment that a modifier is used to modify.
  public enum Target: Sendable {
    case metadataKeys
    case metadataValues
    case blockquotes
    case codeBlocks
    case headings
    case horizontalLines
    case html
    case images
    case inlineCode
    case links
    case lists
    case paragraphs
    case tables
  }
}
