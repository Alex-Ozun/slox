struct Token: Sendable, Equatable {
  let type: TokenType
  let lexeme: String
  let literal: LiteralValue?
  let line: Int
  
  var stringValue: String {
    "\(type) \(lexeme) \(literal.map(String.init) ?? "")"
  }
}

enum LiteralValue: Equatable, Sendable, CustomStringConvertible {
  case string(String)
  case number(Double)
  case boolean(Bool)
  
  var description: String {
    switch self {
    case .string(let string): return string
    case .number(let number): return String(number)
    case .boolean(let boolean): return String(boolean)
    }
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
