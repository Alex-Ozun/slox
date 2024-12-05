import Testing
@testable import slox

@Test func testParser() {
  let tokens: [Token] = [
    Token(type: .minus, lexeme: "-", literal: nil, line: 1),
    Token(type: .number, lexeme: "123", literal: 123, line: 1),
    Token(type: .star, lexeme: "*", literal: nil, line: 1),
    Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
    Token(type: .number, lexeme: "45.67", literal: 45.67, line: 1),
    Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
    Token(type: .eof, lexeme: "", literal: nil, line: 1)
  ]
  let parser = Parser<Expr>(tokens: tokens, onError: { _ in })
  let actual = parser.parse()
  let expected: Expr = makeTestAST()
  #expect(actual == expected)
}
