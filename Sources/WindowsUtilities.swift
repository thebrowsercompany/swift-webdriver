import Foundation
import WinSDK

// Helper to determine if a process with a given name is running
func isProcessRunning(withName name: String) -> Bool {
    let snapshotHandle = CreateToolhelp32Snapshot(DWORD(TH32CS_SNAPPROCESS), 0)
    if snapshotHandle == INVALID_HANDLE_VALUE {
        return false
    }

    defer {
        CloseHandle(snapshotHandle)
    }

    var processEntry = PROCESSENTRY32W()
    processEntry.dwSize = DWORD(MemoryLayout<PROCESSENTRY32W>.size)

    if !Process32FirstW(snapshotHandle, &processEntry) {
        return false
    }

    repeat {
        let capacity = MemoryLayout.size(ofValue: processEntry.szExeFile)
        let processName = withUnsafePointer(to: &processEntry.szExeFile) {
            $0.withMemoryRebound(to: WCHAR.self, capacity: capacity) {
                String(decodingCString: $0, as: UTF16.self)
            }
        }
        if processName == name { 
            return true
        }
    } while Process32NextW(snapshotHandle, &processEntry)

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
