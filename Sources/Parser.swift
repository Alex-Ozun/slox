import Foundation

typealias ParserExpr = Binary & Unary & Literal & Grouping

struct ParserError: Error {
  let token: Token
  let message: String
}

final class Parser<Expr: ParserExpr> {
  private let tokens: [Token]
  private var current: Int = 0
  private let onError: (ParserError) -> Void
  
  init(tokens: [Token], onError: @escaping (ParserError) -> Void) {
    self.tokens = tokens
    self.onError = onError
  }
  
  func parse() -> Expr? {
     do {
       return try expression()
     } catch {
       return nil
     }
   }
  
  private func expression() throws(ParserError) -> Expr {
    return try equality()
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
      return .literal(value: nil)
    } else if match(.number, .string) {
      return .literal(value: previous().literal)
    } else if match(.leftParen) {
      let expression = try expression()
      _ = try consume(.rightParen, errorMessage: "Expect ')' after expression." )
      return .grouping(expression)
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
      
      default: break
      }
      _ = advance()
    }
  }
  
//  private void synchronize() {
//     advance();
//
//     while (!isAtEnd) {
//       if (previous().type == SEMICOLON) return;
//
//       switch (peek().type) {
//         case CLASS:
//         case FUN:
//         case VAR:
//         case FOR:
//         case IF:
//         case WHILE:
//         case PRINT:
//         case RETURN:
//           return;
//       }
//
//       advance();
//     }
//   }
  
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

