import Foundation
import WinSDK

enum WinAppDriverError: Error {
    case win32Error(lastError: Int)
}

public class WinAppDriver: WebDriver {
    static let ip = "127.0.0.1"
    static let port = 4723

    let httpWebDriver: HTTPWebDriver

    private var wadProcessInfo: PROCESS_INFORMATION?

    public init() throws {
        httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(Self.ip):\(Self.port)")!)

        // Ensure WinAppDriver is running.
        if !isProcessRunning(withName: "WinAppDriver.exe") {
            print("Starting WinAppDriver...")

            let path = "\(ProcessInfo.processInfo.environment["ProgramFiles(x86)"]!)\\Windows Application Driver\\WinAppDriver.exe"
            let commandLine = ["\"" + path + "\"", Self.ip, String(Self.port)].joined(separator: " ")
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
                    DWORD(CREATE_UNICODE_ENVIRONMENT),
                    nil,
                    nil,
                    &startupInfo,
                    &processInfo
                ) else {
                    let error = GetLastError()
                    printAndFlush("CreateProcessW failed: \(error)")
                    throw WinAppDriverError.win32Error(lastError: Int(error))
                }

                wadProcessInfo = processInfo
            }
        } else {
            print("WinAppDriver is already running.")
        }
    }

    deinit {
        if let wadProcessInfo {
            CloseHandle(wadProcessInfo.hThread)

            printAndFlush("Terminating WinAppDriver...")
            if !TerminateProcess(wadProcessInfo.hProcess, 0) {
                let error = GetLastError()
                printAndFlush("TerminateProcess failed: \(error)")
            }
            CloseHandle(wadProcessInfo.hProcess)
        }
    }

    @discardableResult
    public func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        try httpWebDriver.send(request)
    }
}
