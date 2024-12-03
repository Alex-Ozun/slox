struct Token {
  let type: TokenType
  let lexeme: String
  let literal: Any? // TODO: revisit
  let line: Int
  
  var stringValue: String {
    "\(type) \(lexeme) \(String(describing: literal))"
  }
}
