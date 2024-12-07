import Foundation

typealias ParserStmt = Block & ExpressionStmt & Print & Var
typealias ParserExpr = Binary & Grouping & Literal & Unary & Variable & Assign

struct ParserError: Error {
  let token: Token
  let message: String
}

final class Parser<Stmt: ParserStmt> where Stmt.ExpressionType: ParserExpr {
  typealias Expr = Stmt.ExpressionType
  private let tokens: [Token]
  private var current: Int = 0
  private let onError: (ParserError) -> Void
  
  init(tokens: [Token], onError: @escaping (ParserError) -> Void) {
    self.tokens = tokens
    self.onError = onError
  }
  
  func parse() -> [Stmt] {
    var statements: [Stmt] = []
    
    while !isAtEnd {
      statements.append(declaration()!) // TODO: revisit optional
    }
    
    return statements
  }
  
  private func declaration() -> Stmt? {
    do {
      if match(.keyword(.var)) {
        return try varDeclaration()
      } else {
        return try statement()
      }
    } catch {
      synchronize()
      return nil
    }
  }
  
  private func varDeclaration() throws(ParserError) -> Stmt {
    let name = try consume(.identifier, errorMessage: "Expect variable name.")
    var initializer: Expr?
    
    if match(.equal) {
      initializer = try expression()
    }
    
    _ = try consume(.semicolon, errorMessage: "Expect ';' after variable.")
    return .var(name: name, initializer: initializer)
  }
  
  private func statement() throws(ParserError) -> Stmt {
    if match(.keyword(.print)) {
      return try printStatement()
    } else if match(.leftBrace) {
      return .block(try block())
    }
    return try expressionStatement()
  }
  
  private func printStatement() throws(ParserError) -> Stmt {
    let expr = try expression()
    _ = try consume(.semicolon, errorMessage: "Expect ';' after value.")
    return .print(expr)
  }
  
  private func block() throws(ParserError) -> [Stmt] {
    var statements: [Stmt] = []
    while !check(.rightBrace) && !isAtEnd {
      let stmt = declaration()! // TODO: revisit force unwrap
      statements.append(stmt)
    }
    _ = try consume(.rightBrace, errorMessage: "Expect '}' after block.")
    return statements
  }
  
//  private List<Stmt> block() {
//      List<Stmt> statements = new ArrayList<>();
//
//      while (!check(RIGHT_BRACE) && !isAtEnd()) {
//        statements.add(declaration());
//      }
//
//      consume(RIGHT_BRACE, "Expect '}' after block.");
//      return statements;
//    }
  
  private func expressionStatement() throws(ParserError) -> Stmt {
    let expr = try expression()
    _ = try consume(.semicolon, errorMessage: "Expect ';' after value.")
    return .expression(expr)
  }
  
  private func expression() throws(ParserError) -> Expr {
    return try assignment()
  }
  
  private func assignment() throws(ParserError) -> Expr {
    let expr = try equality()
    if match(.equal) {
      let equals = previous()
      let expression = try assignment()
      if let variable = expr.variable {
        return .assign(name: variable, expression: expression)
      } else {
        onError(ParserError(token: equals, message: "Invalid assignment target."))
      }
    }
    return expr
  }
  
  private func equality() throws(ParserError) -> Expr {
    var expr = try comparison()
    
    while match(.bangEqual, .equalEqual) {
      let op = previous()
      let right = try comparison()
      expr = .binary(left: expr, operator: op, right: right)
    }
    
    return expr
  }
  
  private func comparison() throws(ParserError) -> Expr {
    var expr = try term()
    
    while match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = previous()
      let right = try term()
      expr = .binary(left: expr, operator: op, right: right)
    }
    
    return expr
  }
  
  private func term() throws(ParserError) -> Expr {
    var expr = try factor()
    
    while match(.minus, .plus) {
      let op = previous()
      let right = try factor()
      expr = .binary(left: expr, operator: op, right: right)
    }
    
    return expr
  }
  
  private func factor() throws(ParserError) -> Expr {
    var expr = try unary()
    
    while match(.slash, .star) {
      let op = previous()
      let right = try unary()
      expr = .binary(left: expr, operator: op, right: right)
    }
    
    return expr
  }
  
  private func unary() throws(ParserError) -> Expr {
    while match(.bang, .minus) {
      let op = previous()
      let operand = try unary()
      return .unary(operator: op, operand: operand)
    }
    
    return try primary()
  }
  
  private func primary() throws(ParserError) -> Expr {
    if match(.keyword(.true)) {
      return .literal(value: true)
    } else if match(.keyword(.false)) {
      return .literal(value: false)
    } else if match(.keyword(.nil)) {
      return .literal(value: .nil)
    } else if match(.number, .string) {
      return .literal(value: previous().literal)
    } else if match(.leftParen) {
      let expression = try expression()
      _ = try consume(.rightParen, errorMessage: "Expect ')' after expression." )
      return .grouping(expression)
    } else if match(.identifier) {
      return .variable(name: previous())
    } else {
      throw ParserError(token: peek(), message: "Expect expression.")
    }
  }
  
  private func `consume`(_ token: TokenType, errorMessage: String) throws(ParserError) -> Token {
    if check(token) {
      return advance()
    } else {
      let error = ParserError(token: peek(), message: errorMessage)
      onError(error)
      throw error
    }
  }
  
  private func synchronize() {
    _ = advance()
    
    while !isAtEnd {
      if previous().type == .semicolon {
        return
      }
      switch peek().type {
      case .keyword(.class),
          .keyword(.fun),
          .keyword(.var),
          .keyword(.for),
          .keyword(.if),
          .keyword(.while),
          .keyword(.print),
          .keyword(.return):
        return
        
      default:
        break
      }
      _ = advance()
    }
  }
  
  private func match(_ tokens: TokenType...) -> Bool {
    for token in tokens {
      if check(token) {
        _ = advance()
        return true
      }
    }
    return false
  }
  
  private func check(_ type: TokenType) -> Bool {
    if isAtEnd {
      return false
    } else {
      return peek().type == type;
    }
  }
  
  private func previous() -> Token {
    tokens[current - 1]
  }
  
  private func advance() -> Token {
    if !isAtEnd {
      current += 1
    }
    return previous()
  }
  
  private func peek() -> Token {
    tokens[current]
  }
  
  private var isAtEnd: Bool {
    peek().type == .eof
  }
}

