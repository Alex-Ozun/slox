import Foundation

protocol Expression {}

protocol Binary: Expression {
  static func binary(left: Self, operator: Token, right: Self) -> Self
}
protocol Grouping: Expression {
  static func grouping(_ expression: Self) -> Self
}
protocol Literal: Expression {
  static func literal(value: Any?) -> Self
}
protocol Unary: Expression {
  static func unary(operator: Token, operand: Self) -> Self
}

indirect enum Expr: Binary, Grouping, Literal, Unary {
  case binary(left: Expr, operator: Token, right: Expr)
  case grouping(Expr)
  case literal(value: Any?)
  case unary(operator: Token, operand: Expr)
}
