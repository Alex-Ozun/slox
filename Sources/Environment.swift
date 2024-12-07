class Environment {
  private var values = [String: LoxValue]()
  
  func define(name: String, value: LoxValue?) {
    values[name] = value
  }
  
  func get(name: Token) throws(RuntimeError) -> LoxValue {
    if let value = values[name.lexeme] {
      return value
    } else {
      throw RuntimeError(token: name, message: "Undefined variable '\(name.lexeme)'.")
    }
  }
}
