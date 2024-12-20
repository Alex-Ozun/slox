import Foundation

enum ScannerError: Error {
  case emptyFile(url: URL)
  case invalidSyntax
  case unexpectedCharacter(line: Int)
  case unterminatedString(line: Int)
}

final class Scanner {
  let source: String
  var tokens: [Token] = []
  let onError: (ScannerError) -> Void
  
  private var start: String.Index
  private var current: String.Index
  private var line = 1
  
  init(source: String, onError: @escaping (ScannerError) -> Void) {
    self.source = source
    self.onError = onError
    self.start = source.startIndex
    self.current = source.startIndex
  }
  
  func scanTokens() -> [Token] {
    while !isAtEnd {
      start = current
      scanToken()
    }
    tokens.append(
      Token(
        type: .eof,
        lexeme: "",
        literal: nil,
        line: line
      )
    )
    return tokens
  }
  
  private func scanToken() {
    let character = advance()
    guard !character.isNewline else {
      line += 1
      return
    }
    guard !character.isWhitespace else { return }
    
    switch character {
    case "(": addToken(.leftParen)
    case ")": addToken(.rightParen)
    case "{": addToken(.leftBrace)
    case "}": addToken(.rightBrace)
    case ",": addToken(.comma)
    case ".": addToken(.dot)
    case "-": addToken(.minus)
    case "+": addToken(.plus)
    case ";": addToken(.semicolon)
    case "*": addToken(.star)
    case "!": addToken(match("=") ? .bangEqual : .bang)
    case "=": addToken(match("=") ? .equalEqual : .equal)
    case "<": addToken(match("=") ? .lessEqual : .less)
    case ">": addToken(match("=") ? .greaterEqual : .greater)
    case "/":
      if match("/") {
        while (!peek().isNewline && !isAtEnd) {
          _ = advance()
        }
      } else {
        addToken(.slash)
      }
    case "\"": string()
    default:
      if character.isDigit {
        number()
      } else if character.isAlpha {
        identifier()
      } else {
        onError(ScannerError.unexpectedCharacter(line: line))
      }
    }
  }
  
  private func identifier() {
    while peek().isAlphaNumeric {
      _ = advance()
    }
    let text = source[start..<current]
    let type: TokenType
    if let keywordType = TokenType.Keyword(rawValue: String(text)) {
      type = .keyword(keywordType)
    } else {
      type = .identifier
    }
    addToken(type)
  }
  
  private func number() {
    while peek().isDigit {
      _ = advance()
    }
    if (peek() == "." && peekNext().isDigit) {
      _ = advance()
      
      while (peek().isDigit) {
        _ = advance()
      }
    }
    let rawLiteral = source[start..<current]
    let literal = Double(rawLiteral).map(LiteralValue.number)
    addToken(.number, literal: literal)
  }
  
  private func peekNext() -> Character {
    let nextIndex = source.index(after: current)
    if nextIndex >= source.endIndex {
      return "\0"
    } else {
      return source[nextIndex]
    }
  }
  
  private func peek() -> Character {
    if isAtEnd {
      return "\0"
    } else {
      return source[current]
    }
  }
               
  private func advance() -> Character {
    let currentCharacter = source[current]
    current = source.index(after: current)
    return currentCharacter
  }
  
  private func addToken(_ type: TokenType, literal: LiteralValue? = nil) {
    let lexeme = String(source[start..<current])
    tokens.append(
      Token(
        type: type,
        lexeme: lexeme,
        literal: literal,
        line: line
      )
    )
  }
   
  private func match(_ expected: Character) -> Bool {
    if isAtEnd {
      return false
    } else if source[current] != expected {
      return false
    } else {
      current = source.index(after: current)
      return true
    }
  }
  
  private func string() {
    while (peek() != "\"" && !isAtEnd) {
      if peek().isNewline {
        line += 1
      }
      _ = advance()
    }
    if isAtEnd {
      onError(.unterminatedString(line: line))
    }
    // The closing ".
    _ = advance()
    // Trim the surrounding quotes.
    let start = source.index(after: start)
    let end = source.index(before: current)
    let literal = String(source[start..<end])
    addToken(.string, literal: .string(literal))
  }
  
  // NB: this should really be called beyond end or something
  private var isAtEnd: Bool {
    current >= source.endIndex
  }
}

extension Character {
  var isDigit: Bool {
    self >= "0" && self <= "9"
  }
  
  var isAlpha: Bool {
    (self >= "a" && self <= "z")
    || (self >= "A" && self <= "Z")
    || self == "_"
  }
  
  var isAlphaNumeric: Bool {
    self.isAlpha || self.isDigit
  }
}
