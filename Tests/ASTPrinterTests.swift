import Testing
@testable import slox

@Test func testASTPrinted() {
  let actual = ASTPrinter.string(for: makeTestAST())
  let expected = "(* (- 123.0) (group 45.67))"
  #expect(actual == expected)
}
