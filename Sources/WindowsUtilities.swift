import Foundation
import WinSDK

// Helper to determine if a process with a given name is running
func isProcessRunning(withName processName: String) -> Bool {
    var processIds: [DWORD] = []
    var bytesReturned: DWORD = 0

    repeat {
        processIds = Array(repeating: 0, count: processIds.count + 1024)
        if !K32EnumProcesses(&processIds, DWORD(processIds.count * MemoryLayout<DWORD>.size), &bytesReturned) {
            return false
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
                    return true
                }
            }
        }
    }
    return false
}

// Helper to enumearate the top level windows and find the one belongging to a given process
func findTopLevelWindow(for process: Process) -> HWND? {
    struct Context {
        let dwProcessId: DWORD
        var hwnd: HWND?
    }
    var context = Context(dwProcessId: DWORD(process.processIdentifier)) 
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
