import Testing
@testable import slox

@Test func testASTPrinted() async throws {
  let actual = ASTPrinter().string(for: buildAST())
  let expected = "(* (- 123) (group 45.67))"
  #expect(actual == expected)
}

// -123 * (45.67)
private func buildAST<E: Binary & Unary & Grouping & Literal>() -> E {
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
