import ArgumentParser
import Foundation

@main
struct slox: AsyncParsableCommand {
  @Argument(transform: URL.init(fileURLWithPath:))
  var inputFile: URL?
  
  mutating func run() async throws {
    if let inputFile {
      try await runFile(url: inputFile)
    } else {
      runPrompt()
    }
  }
}

enum ScannerError: Error {
  case emptyFile(url: URL)
}

func runFile(url inputFile: URL) async throws {
  let fileHandle = try FileHandle(forReadingFrom: inputFile)
  guard let data = try fileHandle.readToEnd() else {
    throw ScannerError.emptyFile(url: inputFile)
  }
  let text = String(decoding: data, as: UTF8.self)
  print(text)
}

func runPrompt() {
  fatalError("umimplemented")
}
