
import Foundation
import WebDriver
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
    public static let defaultStartWaitTime: TimeInterval = 1.0

    private let httpWebDriver: HTTPWebDriver
    private let processTree: Win32ProcessTree?

    private init(httpWebDriver: HTTPWebDriver, processTree: Win32ProcessTree? = nil) {
        self.httpWebDriver = httpWebDriver
        self.processTree = processTree
    }

    public static func attach(ip: String = defaultIp, port: Int = defaultPort) -> WinAppDriver {
        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
        return WinAppDriver(httpWebDriver: httpWebDriver)
    }

    public static func start(
        executablePath: String = defaultExecutablePath,
        ip: String = defaultIp,
        port: Int = defaultPort,
        waitTime: TimeInterval? = defaultStartWaitTime) throws -> WinAppDriver {

        let processTree: Win32ProcessTree
        do {
            processTree = try Win32ProcessTree(path: executablePath, args: [ ip, String(port) ])
        } catch let error as Win32Error {
            throw StartError(message: "Call to Win32 \(error.apiName) failed with error code \(error.errorCode).")
        }

        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)

        // Give WinAppDriver some time to start up
        if let waitTime {
            // TODO(#40): This should be using polling, but an immediate url request would block forever
            Thread.sleep(forTimeInterval: waitTime)

            if let earlyExitCode = try? processTree.exitCode {
                throw StartError(message: "WinAppDriver process exited early with error code \(earlyExitCode).")
            }
        }

        return WinAppDriver(httpWebDriver: httpWebDriver, processTree: processTree)
    }

    deinit {
        if let processTree {
            do {
                try processTree.terminate(waitTime: TimeInterval.infinity)
            } catch {
                assertionFailure("WinAppDriver did not terminate within the expected time: \(error).")
            }
        }
    }

    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        try httpWebDriver.send(request)
    }
}
