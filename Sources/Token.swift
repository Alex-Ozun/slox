struct Token: Sendable, Equatable {
  let type: TokenType
  let lexeme: String
  let literal: LiteralValue?
  let line: Int
  
  var stringValue: String {
    "\(type) \(lexeme) \(literal.map(String.init) ?? "")"
  }
}

public enum LiteralValue: Equatable, Sendable, CustomStringConvertible {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case `nil`
  
  public var description: String {
    switch self {
    case .string(let string):
      return string
      
    case .number(let number):
      let string = String(number)
      if string.hasSuffix(".0") {
        return String(string.dropLast(2))
      } else {
        return string
      }
      
    case .boolean(let boolean):
      return String(boolean)
      
    case .nil:
      return "nil"
    }
  }
}

extension LiteralValue? {
  var unwrappedStringValue: String {
    map(String.init) ?? String(describing: self)
  }
}

extension LiteralValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }
}

extension LiteralValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension LiteralValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .number(value)
  }
}

extension LiteralValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .number(Double(value))
  }
}
