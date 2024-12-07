struct RuntimeError: Error {
  let token: Token
  let message: String
}
  
final class Interpreter {
  private var environment = Environment()
  
  func interpret(_ statements: [Stmt<Expr>], onError: @escaping (RuntimeError) -> Void) {
    do {
      for stmt in statements {
        try execute(stmt)
      }
    } catch {
      onError(error)
    }
  }
  
  private func execute(_ stmt: Stmt<Expr>) throws(RuntimeError) {
    switch stmt {
    case let .block(statements):
      fatalError()
      
    case let .expression(expr):
      _ = try evaluate(expr)
    case let .print(expr):
      let value = try evaluate(expr)
      print(value.unwrappedStringValue)
      
    case let .var(name, initializer):
      var value: LoxValue? = nil
      if let initializer {
        value = try evaluate(initializer)
      }
      environment.define(name: name.lexeme, value: value)
    }
  }
  
  private func executeBlock(
    _ statements: [Stmt<Expr>],
    environment: Environment
  ) throws(RuntimeError) {
    let previousEnvironment = self.environment
    defer { self.environment = previousEnvironment }
    
    self.environment = environment
    for statement in statements {
      try execute(statement)
    }
  }
  
  private func evaluate(_ expr: Expr) throws(RuntimeError) -> LoxValue? { //TODO: revisit return type
    switch expr {
    case let .assign(name, expression):
      let value = try evaluate(expression)
      environment.define(name: name.lexeme, value: value)
      return value
      
    case let .binary(left, `operator`, right):
      let leftValue = try evaluate(left)
      let rightValue = try evaluate(right)
      
      switch (leftValue, `operator`.type, rightValue) {
      case let (.string(leftString), .plus, .string(rightString)):
          return .string(leftString + rightString)
        
      case (.string, .plus, _):
        throw RuntimeError(token: `operator`, message: "Operands must be a strings.")
      // arithmetic
      case let (.number(leftNumber), .minus, .number(rightNumber)):
        return .number(leftNumber - rightNumber)
        
      case let (.number(leftNumber), .plus, .number(rightNumber)):
        return .number(leftNumber + rightNumber)
        
      case let (.number(leftNumber), .slash, .number(rightNumber)):
        return .number(leftNumber / rightNumber)
        
      case let (.number(leftNumber), .star, .number(rightNumber)):
        return .number(leftNumber * rightNumber)
        
      case (_, .minus, _), (.number, .plus, _), (_, .slash, _), (_, .star, _):
        throw RuntimeError(token: `operator`, message: "Operands must be a numbers.")
        
      // comparison
      case let (.number(leftNumber), .greater, .number(rightNumber)):
        return .boolean(leftNumber > rightNumber)
        
      case let (.number(leftNumber), .greaterEqual, .number(rightNumber)):
        return .boolean(leftNumber >= rightNumber)
        
      case let (.number(leftNumber), .less, .number(rightNumber)):
        return .boolean(leftNumber < rightNumber)
        
      case let (.number(leftNumber), .lessEqual, .number(rightNumber)):
        return .boolean(leftNumber <= rightNumber)
        
      case (_, .greater, _), (_, .greaterEqual, _), (_, .less, _), (_, .lessEqual, _):
        throw RuntimeError(token: `operator`, message: "Operands must be a numbers.")
        
      // equality
      case (_ ,.bangEqual, _):
        return .boolean(leftValue != rightValue)
        
      case (_, .equalEqual, _):
        return .boolean(leftValue == rightValue)
        
      default:
        fatalError("unreachable")
      }
      
    case let .grouping(expr):
      return try evaluate(expr)
    
    case let .literal(value):
      return value.map(LoxValue.init)
      
    case let .unary(`operator`, operand):
      let operandValue = try evaluate(operand)
      switch (`operator`.type, operandValue) {
      case let (.minus, .number(number)):
        return .number(-number)
        
      case let (.bang, .some(value)):
        return .boolean(!isTruthy(value))
        
      case (.bang, .none):
        throw RuntimeError(token: `operator`, message: "Operand must be a value.")
        
      case (.minus, _):
        throw RuntimeError(token: `operator`, message: "Operand must be a number.")
        
      default:
        fatalError("unreachable")
      }
      
    case let .variable(name):
      return try environment.getValue(for: name)
    }
  }
  
  private func isTruthy(_ value: LoxValue?) -> Bool {
    switch value {
    case .none:
      return false
    case let .some(.boolean(bool)):
      return bool
    default:
      return true
    }
  }
}
