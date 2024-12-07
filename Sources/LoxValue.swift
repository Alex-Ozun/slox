// TODO: revisit if we still need a separate type from LiteralValue
enum LoxValue: Equatable, CustomStringConvertible {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case `nil`
  
  var description: String {
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

extension LoxValue {
  init(_ value: LiteralValue) {
    switch value {
    case .string(let string): self = .string(string)
    case .number(let number): self = .number(number)
    case .boolean(let boolean): self = .boolean(boolean)
    case .nil: self = .nil
    }
  }
}

extension LoxValue? {
  var unwrappedStringValue: String {
    map(String.init) ?? String(describing: self)
  }
}
