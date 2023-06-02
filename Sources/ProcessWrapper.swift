import Foundation
import WinSDK

// Enum to hold either a Process or a PID (processId) obtained from Windows
// depending on how we launched an application
enum ProcessWrapper {
    case none
    case swift (process: Process?)
    case windows (processId: DWORD)

    var processId: DWORD {
        switch self {
            case .swift(let process):
                return DWORD(process?.processIdentifier ?? 0)
            case .windows(let processId):
                return processId
            default:
                return 0
        }
    }
}
