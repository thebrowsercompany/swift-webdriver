import struct Foundation.TimeInterval
import WinSDK

/// Options for launching a process.
internal struct ProcessLaunchOptions {
    /// Spawn a new console for the process.
    public var spawnNewConsole: Bool = true
    /// Redirect the process's stdout to the given handle.
    public var stdoutHandle: HANDLE? = nil
    /// Redirect the process's stderr to the given handle.
    public var stderrHandle: HANDLE? = nil
    /// Redirect the process's stdin to the given handle.
    public var stdinHandle: HANDLE? = nil
}

/// Starts and tracks the lifetime of a process tree using Win32 APIs.
internal class Win32ProcessTree {
    internal let jobHandle: HANDLE
    internal let handle: HANDLE

    init(path: String, args: [String], options: ProcessLaunchOptions = ProcessLaunchOptions())
        throws {
        // Use a job object to ensure that the process tree doesn't outlive us.
        jobHandle = try Self.createJobObject()

        let commandLine = buildCommandLineArgsString(args: [path] + args)
        do {
            handle = try Self.createProcessInJob(
                commandLine: commandLine, jobHandle: jobHandle, options: options)
        } catch {
            CloseHandle(jobHandle)
            throw error
        }
    }

    var exitCode: DWORD? {
        get throws {
            var result: DWORD = 0
            guard WinSDK.GetExitCodeProcess(handle, &result) else {
                throw Win32Error.getLastError(apiName: "GetExitCodeProcess")
            }
            return result == WinSDK.STILL_ACTIVE ? nil : result
        }
    }

    func terminate(waitTime: TimeInterval?) throws {
        precondition((waitTime ?? 0) >= 0)

        if !TerminateJobObject(jobHandle, UINT.max) {
            throw Win32Error.getLastError(apiName: "TerminateJobObject")
        }

        if let waitTime {
            let milliseconds = waitTime * 1000
            let millisecondsDword = milliseconds > Double(DWORD.max) ? INFINITE : DWORD(milliseconds)
            let waitResult = WaitForSingleObject(handle, millisecondsDword)
            assert(waitResult == WAIT_OBJECT_0, "The process did not terminate within the expected time interval.")
        }
    }

    deinit {
        CloseHandle(handle)
        CloseHandle(jobHandle)
    }

    private static func createJobObject() throws -> HANDLE {
        guard let jobHandle = CreateJobObjectW(nil, nil) else {
            throw Win32Error.getLastError(apiName: "CreateJobObjectW")
        }

        var limitInfo = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
        limitInfo.BasicLimitInformation.LimitFlags = DWORD(JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE) | DWORD(JOB_OBJECT_LIMIT_SILENT_BREAKAWAY_OK)
        guard SetInformationJobObject(jobHandle, JobObjectExtendedLimitInformation,
                &limitInfo, DWORD(MemoryLayout<JOBOBJECT_EXTENDED_LIMIT_INFORMATION>.size)) else {
            defer { CloseHandle(jobHandle) }
            throw Win32Error.getLastError(apiName: "SetInformationJobObject")
        }

        return jobHandle
    }

    private static func createProcessInJob(
        commandLine: String,
        jobHandle: HANDLE,
        options: ProcessLaunchOptions = ProcessLaunchOptions()
    ) throws -> HANDLE {
        try commandLine.withCString(encodedAs: UTF16.self) { commandLine throws in
            var startupInfo = STARTUPINFOW()
            startupInfo.cb = DWORD(MemoryLayout<STARTUPINFOW>.size)
            var redirectStdHandle = false

            let creationFlags =
                DWORD(CREATE_SUSPENDED) | DWORD(CREATE_NEW_PROCESS_GROUP)
                | (options.spawnNewConsole ? DWORD(CREATE_NEW_CONSOLE) : 0)
            if let stdoutHandle = options.stdoutHandle {
                startupInfo.hStdOutput = stdoutHandle
                redirectStdHandle = true
            } else {
                startupInfo.hStdOutput = INVALID_HANDLE_VALUE
            }
            if let stderrHandle = options.stderrHandle {
                startupInfo.hStdError = stderrHandle
                redirectStdHandle = true
            } else {
                startupInfo.hStdError = INVALID_HANDLE_VALUE
            }
            if let stdinHandle = options.stdinHandle {
                startupInfo.hStdInput = stdinHandle
                redirectStdHandle = true
            } else {
                startupInfo.hStdInput = INVALID_HANDLE_VALUE
            }
            if redirectStdHandle {
                startupInfo.dwFlags |= DWORD(STARTF_USESTDHANDLES)
            }

            var processInfo = PROCESS_INFORMATION()
            guard CreateProcessW(
                    nil,
                    UnsafeMutablePointer<WCHAR>(mutating: commandLine),
                    nil,
                    nil,
                    redirectStdHandle, // Inherit handles is necessary for redirects.
                    creationFlags,
                    nil,
                    nil,
                    &startupInfo,
                    &processInfo
            ) else {
                throw Win32Error.getLastError(apiName: "CreateProcessW")
            }

            defer { CloseHandle(processInfo.hThread) }

            guard AssignProcessToJobObject(jobHandle, processInfo.hProcess) else {
                defer { CloseHandle(processInfo.hProcess) }
                throw Win32Error.getLastError(apiName: "AssignProcessToJobObject")
            }

            guard ResumeThread(processInfo.hThread) != DWORD.max else {
                defer { CloseHandle(processInfo.hProcess) }
                throw Win32Error.getLastError(apiName: "ResumeThread")
            }

            return processInfo.hProcess
        }
    }
}
