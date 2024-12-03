import Foundation

enum ScannerError: Error {
  case emptyFile(url: URL)
  case invalidSyntax
  case unexpectedCharacter(line: Int)
}

struct Scanner {
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
  
  mutating func scanTokens() -> [Token] {
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
  
  private mutating func scanToken() {
    switch advance() {
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
        while (peek() != "\n" && !isAtEnd) {
          _ = advance()
        }
      } else {
        addToken(.slash)
      }
    case " ", "\r", "\t": break
    case "\n": line += 1
    default:
      onError(ScannerError.unexpectedCharacter(line: line))
    }
  }
  
  private func peek() -> Character {
    if isAtEnd {
      return "\0"
    } else {
      return source[current]
    }
  }
               
  private mutating func advance() -> Character {
    current = source.index(after: current)
    return source[current]
  }
  
  private mutating func addToken(_ type: TokenType, literal: AnyObject? = nil) {
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
   
  private mutating func match(_ expected: Character) -> Bool {
    if isAtEnd {
      return false
    } else if source[current] != expected {
      return false
    } else {
      current = source.index(after: current)
      return true
    }
  }
  
  private var isAtEnd: Bool {
    return source.index(after: current) == source.endIndex;
  }
}
