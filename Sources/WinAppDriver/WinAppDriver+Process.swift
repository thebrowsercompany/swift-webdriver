import WinSDK

extension WinAppDriver {
    internal class Process {
        internal let jobHandle: HANDLE
        internal let handle: HANDLE

        init(path: String, args: [String]) throws {
            // Use a job object to ensure that the process subtree doesn't outlive us.
            jobHandle = try Self.createJobObject()

            let commandLine = buildCommandLineArgsString(args: [path] + args)
            do { handle = try Self.createProcessInJob(commandLine: commandLine, jobHandle: jobHandle) }
            catch {
                CloseHandle(jobHandle)
                throw error
            }
        }

        func terminate(wholeTree: Bool = true) throws {
            let result = wholeTree 
                ? TerminateJobObject(jobHandle, UINT.max)
                : TerminateProcess(handle, UINT.max)
            if !result {
                try Self.throwLastWin32Error()
            }
        }

        deinit {
            CloseHandle(handle)
            CloseHandle(jobHandle)
        }

        private static func createJobObject() throws -> HANDLE {
            guard let jobHandle = CreateJobObjectW(nil, nil) else {
                try Self.throwLastWin32Error()
            }

            var limitInfo = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
            limitInfo.BasicLimitInformation.LimitFlags = DWORD(JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE) | DWORD(JOB_OBJECT_LIMIT_SILENT_BREAKAWAY_OK)
            guard SetInformationJobObject(jobHandle, JobObjectExtendedLimitInformation,
                &limitInfo, DWORD(MemoryLayout<JOBOBJECT_EXTENDED_LIMIT_INFORMATION>.size)) else {
                CloseHandle(jobHandle)
                try Self.throwLastWin32Error()
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
                    try Self.throwLastWin32Error()
                }

                guard AssignProcessToJobObject(processInfo.hProcess, jobHandle)
                        && ResumeThread(processInfo.hThread) != DWORD.max else {
                    CloseHandle(processInfo.hThread)
                    CloseHandle(processInfo.hProcess)
                    try Self.throwLastWin32Error()
                }

                // We won't need the thread handle
                CloseHandle(processInfo.hThread)
                return processInfo.hProcess
            }
        }

        private static func throwLastWin32Error() throws -> Never {
            throw WinAppDriverError.win32Error(lastError: Int(GetLastError()))
        }
    }
}