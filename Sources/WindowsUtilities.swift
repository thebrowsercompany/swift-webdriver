import Foundation
import WinSDK

// Helper to determine if a process with a given name is running
func isProcessRunning(withName processName: String) -> Bool {
    findProcessId(withName: processName) != 0
}

// Helper to find the id of a process by name
// Return 0 if process not found
func findProcessId(withName processName: String) -> DWORD {
    var processIds: [DWORD] = []
    var bytesReturned: DWORD = 0

    repeat {
        processIds = Array(repeating: 0, count: processIds.count + 1024)
        if !K32EnumProcesses(&processIds, DWORD(processIds.count * MemoryLayout<DWORD>.size), &bytesReturned) {
            return 0
        }
    } while bytesReturned == DWORD(processIds.count * MemoryLayout<DWORD>.size)

    let processCount = Int(bytesReturned) / MemoryLayout<DWORD>.size

    for i in 0..<processCount {
        let processId = processIds[i]
        let processHandle = OpenProcess(DWORD(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ), false, processId)

        if processHandle != nil {
            defer {
                CloseHandle(processHandle)
            }

            var processNameBuffer: [WCHAR] = Array(repeating: 0, count: Int(MAX_PATH))
            if K32GetModuleBaseNameW(processHandle, nil, &processNameBuffer, DWORD(processNameBuffer.count)) > 0 {
                let processNameString = String(decodingCString: processNameBuffer, as: UTF16.self)

                if processNameString.lowercased() == processName.lowercased() {
                    return processId
                }
            }
        }
    }
    return 0
}

// Helper to enumearate the top level windows and find the one belongging to a given process
func findTopLevelWindow(for process: Process) -> HWND? {
    findTopLevelWindow(for: DWORD(bitPattern: process.processIdentifier))
}

// Helper to enumearate the top level windows and find the one belongging to a given process by id
func findTopLevelWindow(for processId: DWORD) -> HWND? {
    struct Context {
        let dwProcessId: DWORD
        var hwnd: HWND?
    }
    var context = Context(dwProcessId: DWORD(processId)) 
    let callback: @convention(c) (HWND?, LPARAM) -> WindowsBool = { (hwnd, lParam) in
        let pContext = UnsafeMutablePointer<Context>(bitPattern: UInt(lParam))!
        var pid: DWORD = 0
        GetWindowThreadProcessId(hwnd, &pid)
        if pid == pContext.pointee.dwProcessId {
            pContext.pointee.hwnd = hwnd
            return false
        }
        return true
    }
    _ = withUnsafePointer(to: &context) {
        EnumWindows(callback, LPARAM(UInt(bitPattern: $0)))
    }
    return context.hwnd
}

// Helper to Shell execute an app identified by URL
// and retrieve the launch process id
func openURL(_ url: String, args: [String]? = nil, workingDir: String? = nil) -> DWORD {
    let verb = "open"
    let processId = verb.withCString { verb in
        url.withCString { url in
            (args?.joined(separator: " ") ?? "").withCString { args in
                (workingDir ?? "").withCString { workingDir in

                    var sei: SHELLEXECUTEINFO = SHELLEXECUTEINFO()
                    sei.cbSize = DWORD(MemoryLayout<SHELLEXECUTEINFO>.size)
                    sei.fMask = ULONG(SEE_MASK_NOCLOSEPROCESS)
                    sei.lpVerb = verb
                    sei.lpFile = url
                    sei.lpParameters = args
                    sei.lpDirectory = workingDir
                    sei.nShow = Int32(SW_SHOWNORMAL)

                    guard ShellExecuteExA(&sei) else {
                        fatalError("Failed to open URL: \(url)")
                    }

                    return GetProcessId(sei.hProcess)
                }
            }
        }
    }

    return processId
}

// Helper to extract the exe name out of a path to an exe file
func getExeName(fromPath path: String) -> String? {
    if let url = URL(string: path) {
        return url.lastPathComponent
    }
    let url = URL(fileURLWithPath: path)
    return url.lastPathComponent
}
