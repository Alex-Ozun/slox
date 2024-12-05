@testable import slox

/// -123 * (45.67)
func makeTestAST<E: Binary & Unary & Grouping & Literal>() -> E {
  .binary(
    left: .unary(
      operator: Token(
        type: .minus,
        lexeme: "-",
        literal: nil,
        line: 1
      ),
      operand: .literal(value: 123)
    ),
    operator: Token(
      type: .star,
      lexeme: "*",
      literal: nil,
      line: 1
    ),
    right: .grouping(.literal(value: 45.67))
  )
}
