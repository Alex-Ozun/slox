import Foundation

protocol Expression {}

protocol Binary: Expression {
  static func binary(left: Self, operator: Token, right: Self) -> Self
}
protocol Grouping: Expression {
  static func grouping(_ expression: Self) -> Self
}
protocol Literal: Expression {
  static func literal(value: LiteralValue?) -> Self
}
protocol Unary: Expression {
  static func unary(operator: Token, operand: Self) -> Self
}
protocol Variable: Expression {
  static func variable(name: Token) -> Self
  var variable: Token? { get }
}
protocol Assign: Expression {
  static func assign(name: Token, expression: Self) -> Self
}

indirect enum Expr: Sendable, Equatable, Binary, Grouping, Literal, Unary, Variable, Assign {
  case assign(name: Token, expression: Expr)
  case binary(left: Expr, operator: Token, right: Expr)
  case grouping(Expr)
  case literal(value: LiteralValue?)
  case unary(operator: Token, operand: Expr)
  case variable(name: Token)
  
  var variable: Token? {
    switch self {
    case let .variable(name):
      return name
    default:
      return nil
    }
  }
}
