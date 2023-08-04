import Foundation
import WinSDK

public enum WinAppDriverError: Error {
    // Exposes any underlying win32 errors that may surface as a result of process management.
    case win32Error(lastError: Int)

    // Attempting to attach to existing driver, but no existing WinAppDriver process was found.
    case processNotFound

    // Attempting to launch WinAppDriver, but it's already running.
    case alreadyRunning
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

        // On local hosts, we can check if the process is running.
        if ip == WinAppDriver.defaultIp {
            guard isProcessRunning(withName: Self.processsName) else {
                throw WinAppDriverError.processNotFound
            }
        }

        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
    }

    public init() throws {
        ip = WinAppDriver.defaultIp
        port = WinAppDriver.defaultPort

        guard !isProcessRunning(withName: Self.processsName) else {
            throw WinAppDriverError.alreadyRunning
        }

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
        }
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}
