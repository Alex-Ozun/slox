protocol Statement {
  associatedtype ExpressionType: Expression
}

protocol ExpressionStmt: Statement {
  static func expression(_ expression: ExpressionType) -> Self
}

protocol Print: Statement {
  static func print(_ expression: ExpressionType) -> Self
}

protocol Var: Statement {
  static func `var`(name: Token, initializer: ExpressionType?) -> Self
}

protocol Block: Statement {
  static func block(_ statements: [Self]) -> Self
}

indirect enum Stmt<ExpressionType: Expression & Sendable & Equatable>: Sendable, Equatable, ExpressionStmt, Print, Var, Block {
  case block([Stmt])
  case expression(_ expression: ExpressionType)
  case print(_ expression: ExpressionType)
  case `var`(name: Token, initializer: ExpressionType?)
}
