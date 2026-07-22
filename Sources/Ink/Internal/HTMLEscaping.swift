/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal enum HTMLEscaping {
  /// Escape `<`, `>`, and `&` exactly as Ink's `Reader`-driven emitter did.
  internal static func escape(_ string: String) -> String {
    var result = ""
    result.reserveCapacity(string.count)
    for character in string {
      switch character {
      case "<": result.append("&lt;")
      case ">": result.append("&gt;")
      case "&": result.append("&amp;")
      default: result.append(character)
      }
    }
    return result
  }
}
