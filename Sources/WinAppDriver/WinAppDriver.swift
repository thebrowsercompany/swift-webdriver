
import Foundation
import WinSDK

public class WinAppDriver: WebDriver {
    /// Raised when the WinAppDriver.exe process fails to start
    public struct StartError: Error {
        public var message: String
    }

    public static let defaultIp = "127.0.0.1"
    public static let defaultPort = 4723
    public static let executableName = "WinAppDriver.exe"
    public static var defaultExecutablePath: String {
        let programFilesX86 = ProcessInfo.processInfo.environment["ProgramFiles(x86)"]
            ?? "\(ProcessInfo.processInfo.environment["SystemDrive"] ?? "C:")\\Program Files (x86)"
        return "\(programFilesX86)\\Windows Application Driver\\\(executableName)"
    }

    private var processTree: Win32ProcessTree?
    private let httpWebDriver: HTTPWebDriver

    public init(attachingTo ip: String, port: Int = WinAppDriver.defaultPort) {
        self.httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    public init(startingProcess executablePath: String = defaultExecutablePath, ip: String = WinAppDriver.defaultIp, port: Int = WinAppDriver.defaultPort) throws {
        do {
            self.processTree = try Win32ProcessTree(path: executablePath, args: [ ip, String(port) ])
        } catch let error as Win32Error {
            throw StartError(message: "Call to Win32 \(error.apiName) failed with error code \(error.errorCode).")
        }

        // This gives some time for WinAppDriver to get up and running before
        // we hammer it with requests, otherwise some requests will timeout.
        Thread.sleep(forTimeInterval: 1.0)

        self.httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    deinit {
        if let processTree {
            do {
                try processTree.terminate()
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
