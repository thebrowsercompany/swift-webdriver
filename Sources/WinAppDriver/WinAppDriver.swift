
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
    private var processTree: Win32ProcessTree?
    /// The write end of a pipe that is connected to the child process's stdin.
    private var childStdinHandle: HANDLE?

    private init(
        httpWebDriver: HTTPWebDriver,
        processTree: Win32ProcessTree? = nil,
        childStdinHandle: HANDLE? = nil) {
        self.httpWebDriver = httpWebDriver
        self.processTree = processTree
        self.childStdinHandle = childStdinHandle
    }

    public static func attach(ip: String = defaultIp, port: Int = defaultPort) -> WinAppDriver {
        let httpWebDriver = HTTPWebDriver(endpoint: URL(string: "http://\(ip):\(port)")!)
        return WinAppDriver(httpWebDriver: httpWebDriver)
    }

    public static func start(
        executablePath: String = defaultExecutablePath,
        ip: String = defaultIp,
        port: Int = defaultPort,
        waitTime: TimeInterval? = defaultStartWaitTime,
        outputFile: String? = nil) throws -> WinAppDriver {
        let processTree: Win32ProcessTree
        var childStdinHandle: HANDLE? = nil
        do {
            var launchOptions = ProcessLaunchOptions()

            // Close our handles when the process has launched. The child process keeps a copy.
            defer {
                if let handle = launchOptions.stdoutHandle {
                    CloseHandle(handle)
                }
                if let handle = launchOptions.stdinHandle {
                    CloseHandle(handle)
                }
            }

            if let outputFile = outputFile {
                // Open the output file for writing to the child stdout.
                var securityAttributes = SECURITY_ATTRIBUTES()
                securityAttributes.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
                securityAttributes.bInheritHandle = true
                launchOptions.stdoutHandle = outputFile.withCString(encodedAs: UTF16.self) {
                    outputFile in
                    CreateFileW(
                        UnsafeMutablePointer<WCHAR>(mutating: outputFile), DWORD(GENERIC_WRITE),
                        DWORD(FILE_SHARE_READ), &securityAttributes,
                        DWORD(OPEN_ALWAYS), DWORD(FILE_ATTRIBUTE_NORMAL), nil)
                }
                if launchOptions.stdoutHandle == INVALID_HANDLE_VALUE {
                    // Failed to open the output file for writing.
                    throw Win32Error.getLastError(apiName: "CreateFileW")
                }

                // Use the same handle for stderr.
                launchOptions.stderrHandle = launchOptions.stdoutHandle

                // WinAppDriver will close immediately if no stdin is provided so create a dummy
                // pipe here to keep stdin open until the child process is closed.
                var childReadInputHandle: HANDLE?
                if !CreatePipe(&childReadInputHandle, &childStdinHandle, &securityAttributes, 0) {
                    throw Win32Error.getLastError(apiName: "CreatePipe")
                }
                launchOptions.stdinHandle = childReadInputHandle

                // Also use the parent console to stop spurious new consoles from spawning.
                launchOptions.spawnNewConsole = false
            }

            processTree = try Win32ProcessTree(
                path: executablePath, args: [ip, String(port)], options: launchOptions)
        } catch let error as Win32Error {
            CloseHandle(childStdinHandle)
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

        return WinAppDriver(
            httpWebDriver: httpWebDriver,
            processTree: processTree,
            childStdinHandle: childStdinHandle)
    }

    deinit {
        try? close() // Call close() directly to handle errors. 
    }

    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        try httpWebDriver.send(request)
    }

    public func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool {
        error == .winAppDriver_elementNotInteractable || httpWebDriver.isInconclusiveInteraction(error: error)
    }

    public func close() throws {
        if let childStdinHandle {
            CloseHandle(childStdinHandle)
            self.childStdinHandle = nil
        }

        if let processTree {
            try processTree.terminate(waitTime: TimeInterval.infinity)
            self.processTree = nil
        }
    }
}
