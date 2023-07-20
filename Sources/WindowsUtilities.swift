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
        guard let processHandle = OpenProcess(DWORD(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ), false, processId) else {
            continue
        }

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
    return false
}
