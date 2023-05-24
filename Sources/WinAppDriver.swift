import Foundation

public class WinAppDriver: WebDriver {
    static let ip = "127.0.0.1"
    static let port = 4723

    let httpWebDriver: HTTPWebDriver

    public init() throws {
        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(Self.ip):\(Self.port)")!)
    }

    // let process: Process
    // let toStdinPipe: Pipe

    // init() throws {
        // let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"
        
        // toStdinPipe = Pipe()
        // process = Process()
        // process.executableURL = URL(fileURLWithPath: path)
        // process.arguments = [ Self.ip, String(Self.port) ]
        // process.standardInput = toStdinPipe.fileHandleForReading
        // process.standardOutput = nil
        // do {
        //     try process.run()
        // } catch {
        //     fatalError("Could not start AppWinDriver!")
        // }
    // }

    // deinit {
    //     // WinAppDriver responds waits for a key to return
    //     try? toStdinPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .utf8)!)
    //     process.terminate()
    // }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}