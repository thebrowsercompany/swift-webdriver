
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
    public static let defaultStartWaitTime: TimeInterval = 1.0

    private let httpWebDriver: HTTPWebDriver
    private let processTree: Win32ProcessTree?
    private var terminationWaitTime: TimeInterval?

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
            let statusResult = poll(timeout: waitTime) {
                let result = Result { try httpWebDriver.send(Requests.Status()) }
                return PollResult(value: result, success: (try? result.get()) != nil)
            }.value

            if case .failure(let error) = statusResult {
                throw StartError(message: "WinAppDriver did not respond within the expected time after startup: \(error).")
            }
        }

        let result = WinAppDriver(httpWebDriver: httpWebDriver, processTree: processTree)
        result.terminationWaitTime = waitTime
        return result
    }

    deinit {
        if let processTree {
            do {
                try processTree.terminate(waitTime: terminationWaitTime)
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
