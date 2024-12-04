struct Token: Sendable {
  let type: TokenType
  let lexeme: String
  let literal: (any Sendable)? // TODO: revisit
  let line: Int
  
  var stringValue: String {
    "\(type) \(lexeme) \(String(describing: literal))"
  }
}
