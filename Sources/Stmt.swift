protocol Statement {
  associatedtype ExpressionType: Expression
}


protocol ExpressionStmt: Statement {
  static func expression(_ expression: ExpressionType) -> Self
}

protocol Print: Statement {
  static func print(_ expression: ExpressionType) -> Self
}

indirect enum Stmt<ExpressionType: Expression & Sendable & Equatable>: Sendable, Equatable, ExpressionStmt, Print {
  case expression(_ expression: ExpressionType)
  case print(_ expression: ExpressionType)
}
