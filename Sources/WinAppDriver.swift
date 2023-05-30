import Foundation
import WinSDK

public class WinAppDriver: WebDriver {
    static let ip = "127.0.0.1"
    static let port = 4723

    let httpWebDriver: HTTPWebDriver

    struct RunningProcess {
        var process: Process
        var toStdinPipe: Pipe
    }
    var runningProcess: RunningProcess? = nil

    init() throws {
        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(Self.ip):\(Self.port)")!)
        
        // We start WinAppDriver only if its process is not already started
        // CI machines start it using a GitHub action before running the tests 
        // to get around https://linear.app/the-browser-company/issue/WIN-569/winappdriver-does-not-work-on-ci
        if !isProcessRunning(withName: "WinAppDriver.exe") {
            let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"

            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = [ Self.ip, String(Self.port) ]
            process.standardInput = pipe.fileHandleForReading
            process.standardOutput = nil
            runningProcess = RunningProcess(process: process, toStdinPipe: pipe)
            do {
                try runningProcess!.process.run()
            } catch {
                fatalError("Could not start WinAppDriver!")
            }
        }
    }

    deinit {
        // WinAppDriver responds waits for a key to return
        if let runningProcess = runningProcess {
            try? runningProcess.toStdinPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .utf8)!)
            runningProcess.process.terminate()
        }
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}