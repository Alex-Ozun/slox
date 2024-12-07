final class Environment {
  let enclosing: Environment?
  private var values = [String: LoxValue]()
  
  init(enclosing: Environment? = nil) {
    self.enclosing = enclosing
  }
  
  func define(name: String, value: LoxValue?) {
    values[name] = value
  }
  
  func assign(to name: Token, value: LoxValue) throws(RuntimeError) {
    if values[name.lexeme] != nil {
      values[name.lexeme] = value
    }  else if let enclosing {
      return try enclosing.assign(to: name, value: value)
    }else {
      throw RuntimeError(token: name, message: "Undefined variable '\(name.lexeme)'.")
    }
  }
  
  func getValue(for name: Token) throws(RuntimeError) -> LoxValue {
    if let value = values[name.lexeme] {
      return value
    } else if let enclosing {
      return try enclosing.getValue(for: name)
    } else {
      throw RuntimeError(token: name, message: "Undefined variable '\(name.lexeme)'.")
    }
  }
}
