
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
        "\(WindowsSystemPaths.programFilesX86)\\Windows Application Driver\\\(executableName)"
    }

    private let httpWebDriver: HTTPWebDriver
    private var processTree: Win32ProcessTree?

    private init(httpWebDriver: HTTPWebDriver, processTree: Win32ProcessTree? = nil) {
        self.httpWebDriver = httpWebDriver
        self.processTree = processTree
    }

    public static func attach(ip: String = defaultIp, port: Int = WinAppDriver.defaultPort) -> WinAppDriver {
        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
        return WinAppDriver(httpWebDriver: httpWebDriver)
    }

    public static func start(
        executablePath: String = defaultExecutablePath,
        ip: String = WinAppDriver.defaultIp,
        port: Int = WinAppDriver.defaultPort) throws -> WinAppDriver {

        let processTree: Win32ProcessTree
        do {
            processTree = try Win32ProcessTree(path: executablePath, args: [ ip, String(port) ])
        } catch let error as Win32Error {
            throw StartError(message: "Call to Win32 \(error.apiName) failed with error code \(error.errorCode).")
        }

        // This gives some time for WinAppDriver to get up and running before
        // we hammer it with requests, otherwise some requests will timeout.
        Thread.sleep(forTimeInterval: 1.0)

        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
        return WinAppDriver(httpWebDriver: httpWebDriver, processTree: processTree)
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
