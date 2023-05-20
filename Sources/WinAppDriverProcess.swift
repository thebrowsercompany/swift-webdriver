import Foundation

class WinAppDriverProcess {
    static let ip = "127.0.0.1"
    static let port = 4723

    let process: Process
    let toStdinPipe: Pipe

    init() throws {
        // let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"
        let path = "\(ProcessInfo.processInfo.environment["WINDIR"]!)\\notepad.exe"
        
        toStdinPipe = Pipe()
        process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = [ Self.ip, String(Self.port) ]
        process.standardInput = toStdinPipe.fileHandleForReading
        process.standardOutput = nil


        "sending task to the background thread..."
            .data(using: .utf8)
            .map(FileHandle.standardError.write)

        DispatchQueue.global(qos: .background).async {
            "is background thread"
                .data(using: .utf8)
                .map(FileHandle.standardError.write)

            do {
                try self.process.run()
            } catch {
                fatalError("Could not start AppWinDriver!")
            }
        }

       // abort()
    }

    deinit {
        // WinAppDriver responds waits for a key to return
        try? toStdinPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .utf8)!)
        process.terminate()
    }

    var endpoint : URL { URL(string: "http://\(Self.ip):\(Self.port)")! }
}
