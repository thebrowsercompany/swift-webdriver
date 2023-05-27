import Foundation
import WinSDK

public class WinAppDriver: WebDriver {
    static let ip = "127.0.0.1"
    static let port = 4723

    let httpWebDriver: HTTPWebDriver

    struct RunningProcess {
        init() {
            process = Process()
            toStdinPipe = Pipe()
        }
        var process: Process
        var toStdinPipe: Pipe
    }
    var runningProcess: RunningProcess? = nil

    init() throws {
        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(Self.ip):\(Self.port)")!)
        
        if !isProcessRunning(withName: "WinAppDriver.exe") {
            // If we don't get status back from the server, we assume it needs to be started

            let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"

            runningProcess = RunningProcess()
            if let runningProcess = runningProcess {
                runningProcess.process.executableURL = URL(fileURLWithPath: path)
                runningProcess.process.arguments = [ Self.ip, String(Self.port) ]
                runningProcess.process.standardInput = runningProcess.toStdinPipe.fileHandleForReading
                runningProcess.process.standardOutput = nil
                do {
                    try runningProcess.process.run()
                } catch {
                    fatalError("Could not start WinAppDriver!")
                }
            }
        }
    }

    deinit {
        // WinAppDriver responds waits for a key to return
        try? runningProcess?.toStdinPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .utf8)!)
        runningProcess?.process.terminate()
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}