import ArgumentParser
import Foundation

@main
final class slox: AsyncParsableCommand {
  @Argument(transform: URL.init(fileURLWithPath:))
  var inputFile: URL?
  var hadError = false // weird, but OK

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
    print("source", source)
    run(source: source)
    if hadError {
      throw ScannerError.invalidSyntax
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
    let parser = Parser<Expr>(
      tokens: tokens,
      onError: { error in
        self.error(token: error.token, message: error.message)
      }
    )
    if let expr = parser.parse(), !hadError {
      print(ASTPrinter.string(for: expr))
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
}

enum LoxError: Error {
  case invalidSyntax
}
