import ArgumentParser
import Foundation

enum SloxError: Error {
  case syntaxError
  case runtimeError
}

// TODO: revisit
nonisolated(unsafe) let interpreter = Interpreter()

@main
final class slox: AsyncParsableCommand {
  @Argument(transform: URL.init(fileURLWithPath:))
  var inputFile: URL?
  var hadError = false // weird, but OK
  var hadRuntimeError = false
  
  func run() async throws {
    if let inputFile {
      try await runFile(url: inputFile)
    } else {
      runPrompt()
    }
  }
  
  func runFile(url inputFile: URL) async throws {
    let fileHandle = try FileHandle(forReadingFrom: inputFile)
    guard let data = try fileHandle.readToEnd() else {
      throw ScannerError.emptyFile(url: inputFile)
    }
    let source = String(decoding: data, as: UTF8.self)
    print("Source code:")
    print(source)
    run(source: source)
    if hadError {
      throw SloxError.syntaxError
    }
    if hadRuntimeError {
      throw SloxError.runtimeError
    }
  }
  
  func runPrompt() {
    while true {
      print("> ", terminator: "")
      //    if let data = try? FileHandle.standardInput.readToEnd() {
      //      let line = String(decoding: data, as: UTF8.self)
      if let line = readLine() {
        print("line", line)
        run(source: line)
        hadError = false
      } else {
        break
      }
    }
  }
  
  func run(source: String) {
    let scanner = Scanner(
      source: source,
      onError: { error in
        switch error {
        case let .unexpectedCharacter(lineNumber):
          self.error(lineNumber: lineNumber, message: "Unexpected character")
        case let .unterminatedString(lineNumber):
          self.error(lineNumber: lineNumber, message: "Unterminated string")
        default: break
        }
      }
    )
    let tokens = scanner.scanTokens()
//    print("tokens", tokens)
    let parser = Parser<Stmt<Expr>>(
      tokens: tokens,
      onError: { error in
        self.error(token: error.token, message: error.message)
      }
    )
    let statements = parser.parse()
    if !hadError {
//      print(ASTPrinter.string(for: expr))
      interpreter.interpret(statements) { error in
        self.runtimeError(error)
      }
    }
  }
  
  func error(lineNumber: Int, message: String) {
    report(lineNumber: lineNumber, where: "", message: message)
  }
  
  func report(lineNumber: Int, `where`: String, message: String) {
    let output = "[line \(lineNumber)] Error \(`where`): \(message)"
    FileHandle.standardError.write(Data(output.utf8))
    hadError = true
  }
  
  func error(token: Token, message: String) {
    if token.type == .eof {
      report(lineNumber: token.line, where: " at end", message: message)
    } else {
      report(lineNumber: token.line, where: " at '\(token.lexeme)'", message: message)
    }
  }
  
  func runtimeError(_ error: RuntimeError) {
    print(error.message + "\n[line \(error.token.line)]")
    hadRuntimeError = true
  }
}

enum LoxError: Error {
  case invalidSyntax
}
