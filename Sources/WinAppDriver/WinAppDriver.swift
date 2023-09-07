
import Foundation
import WinSDK

public enum WinAppDriverError: Error {
    // Exposes any underlying win32 errors that may surface as a result of process management.
    case win32Error(lastError: Int)
}

public class WinAppDriver: WebDriver {
    public static let defaultIp = "127.0.0.1"
    public static let defaultPort = 4723
    public static let executableName = "WinAppDriver.exe"
    public static var defaultExecutablePath: String {
        let programFilesX86 = ProcessInfo.processInfo.environment["ProgramFiles(x86)"]
            ?? "\(ProcessInfo.processInfo.environment["SystemDrive"] ?? "C:")\\Program Files (x86)"
        return "\(programFilesX86)\\Windows Application Driver\\\(executableName)"
    }

    private var process: Process?
    private let httpWebDriver: HTTPWebDriver

    public init(attachingTo ip: String, port: Int = WinAppDriver.defaultPort) throws {
        self.httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    public init(_ ip: String = WinAppDriver.defaultIp, port: Int = WinAppDriver.defaultPort) throws {
        self.process = try Process(path: Self.defaultExecutablePath, args: [ ip, String(port) ])

        // This gives some time for WinAppDriver to get up and running before
        // we hammer it with requests, otherwise some requests will timeout.
        Thread.sleep(forTimeInterval: 1.0)

        self.httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    deinit {
        if let process {
            do {
                try process.terminate()
            } catch {
                assertionFailure("TerminateProcess failed with error \(error).")
            }

            // Add a short delay to let process cleanup happen before we try
            // to launch another instance.
            Thread.sleep(forTimeInterval: 1.0)
        }
    }

    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        try httpWebDriver.send(request)
    }
}
