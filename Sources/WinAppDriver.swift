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
            Thread.sleep(forTimeInterval: 1.0)
        }
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        return try httpWebDriver.send(request)
    }
}
