import Foundation

class WinAppDriverProcess {
    let process: Process
    let toStdinPipe: Pipe

    init() throws {
        toStdinPipe = Pipe()

        process = Process()
        process.executableURL = URL(fileURLWithPath: "C:\\Program Files (x86)\\Windows Application Driver\\WinAppDriver.exe")
        process.arguments = [ "127.0.0.1", "4723" ]
        process.standardInput = toStdinPipe.fileHandleForReading
        process.standardOutput = nil
        try process.run()
    }

    deinit {
        // WinAppDriver responds waits for a key to return
        try? toStdinPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .utf8)!)
        process.terminate()
    }

    var url : URL { URL(string: "http://127.0.0.1:4723")! }
}