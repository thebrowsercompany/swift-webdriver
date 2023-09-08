import WinSDK

/// Starts and tracks the lifetime of a process tree using Win32 APIs.
internal class Win32ProcessTree {
    internal let jobHandle: HANDLE
    internal let handle: HANDLE

    init(path: String, args: [String]) throws {
        // Use a job object to ensure that the process tree doesn't outlive us.
        jobHandle = try Self.createJobObject()

        let commandLine = buildCommandLineArgsString(args: [path] + args)
        do { handle = try Self.createProcessInJob(commandLine: commandLine, jobHandle: jobHandle) }
        catch {
            CloseHandle(jobHandle)
            throw error
        }
    }

    func terminate() throws {
        if !TerminateJobObject(jobHandle, UINT.max) {
            throw Win32Error.getLastError(apiName: "TerminateJobObject")
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

    private static func createProcessInJob(commandLine: String, jobHandle: HANDLE) throws -> HANDLE {
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
                DWORD(CREATE_NEW_CONSOLE) | DWORD(CREATE_SUSPENDED) | DWORD(CREATE_NEW_PROCESS_GROUP),
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