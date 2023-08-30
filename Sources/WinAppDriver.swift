import Foundation
import WinSDK

public enum WinAppDriverError: Error {
    // Exposes any underlying win32 errors that may surface as a result of process management.
    case win32Error(lastError: Int)
}

public class WinAppDriver: WebDriver {
    public static let defaultIp = "127.0.0.1"
    public static let defaultPort = 4723

    static let processsName = "WinAppDriver.exe"

    private let httpWebDriver: HTTPWebDriver

    private let port: Int
    private let ip: String

    private var wadProcessInfo: PROCESS_INFORMATION?

    public init(attachingTo ip: String, port: Int = WinAppDriver.defaultPort) throws {
        self.ip = ip
        self.port = port

        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    public init(_ ip: String = WinAppDriver.defaultIp, port: Int = WinAppDriver.defaultPort) throws {
        self.ip = ip
        self.port = port

        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)

        let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"
        let commandLine = ["\"\(path)\"", ip, String(port)].joined(separator: " ")
        try commandLine.withCString(encodedAs: UTF16.self) { commandLine throws in
            var startupInfo = STARTUPINFOW()
            startupInfo.cb = DWORD(MemoryLayout<STARTUPINFOW>.size)

            var processInfo = PROCESS_INFORMATION()
            guard CreateProcessW(
                nil,
                UnsafeMutablePointer<WCHAR>(mutating: commandLine),
                nil,
                nil,
                false,
                DWORD(CREATE_NEW_CONSOLE),
                nil,
                nil,
                &startupInfo,
                &processInfo
            ) else {
                throw WinAppDriverError.win32Error(lastError: Int(GetLastError()))
            }

            wadProcessInfo = processInfo

            // This gives some time for WinAppDriver to get up and running before
            // we hammer it with requests, otherwise some requests will timeout.
            Thread.sleep(forTimeInterval: 1.0)
        }
    }

    deinit {
        if let wadProcessInfo {
            CloseHandle(wadProcessInfo.hThread)

            if !TerminateProcess(wadProcessInfo.hProcess, 0) {
                let error = GetLastError()
                assertionFailure("TerminateProcess failed with error \(error).")
            }
            CloseHandle(wadProcessInfo.hProcess)

            // Add a short delay to let process cleanup happen before we try
            // to launch another instance.
            Thread.sleep(forTimeInterval: 1.0)
        }
    }

    /// newSession(app:) - Creates a new WinAppDriver session
    /// - app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch
    /// - appWorkingDir: working directory to run the app in
    /// - waitForAppLaunch: time to wait to the app to launch in seconds, 0 by default
    /// - Returns: new Session instance
    public func newSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil, waitForAppLaunch: Int? = nil) throws -> Session {
        let capabilities = ExtensionCapabilities()
        capabilities.app = app
        capabilities.appArguments = appArguments?.joined(separator: " ")
        capabilities.appWorkingDir = appWorkingDir
        capabilities.waitForAppLaunch = waitForAppLaunch
        let response = try send(WebDriverRequests.Session(desiredCapabilities: capabilities))
        return Session(in: self, id: response.sessionId, capabilities: response.value)
    }

    /// newSession(appTopLevelWindowHandle:)
    /// Creates a new session attached to an existing app top level window
    /// - Parameter appTopLevelWindowHandle: the window handle
    /// - Returns: new Session instance
    public func newSession(appTopLevelWindowHandle: UInt) throws -> Session {
        let capabilities = ExtensionCapabilities()
        capabilities.appTopLevelWindow = String(appTopLevelWindowHandle, radix: 16)
        let response = try send(WebDriverRequests.Session(desiredCapabilities: capabilities))
        return Session(in: self, id: response.sessionId, capabilities: response.value)
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}
