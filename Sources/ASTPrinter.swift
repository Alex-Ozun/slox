enum ASTPrinter {
  static func string(for expr: Expr) -> String {
    switch expr {
    case let .binary(left, `operator`, right):
      return parenthesize(`operator`.lexeme, left, right)
    
    case let .grouping(expr):
      return parenthesize("group", expr)
      
    case let .literal(value):
      if let value {
        return String(describing: value)
      } else {
        return "nil"
      }
      
    case let .unary(`operator`, operand):
      return parenthesize(`operator`.lexeme, operand)
    }
  }
  
  private static func parenthesize(_ name: String, _ exprs: Expr...) -> String {
    var result: String = ""
    result.append("(")
    result.append(name)
    for expr in exprs {
      result.append(" ")
      result.append(string(for: expr))
    }
    result.append(")")
    return result
  }
}
