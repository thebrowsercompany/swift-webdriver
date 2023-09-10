import class Foundation.ProcessInfo

enum WindowsSystemPaths {
    static var systemDrive: String { ProcessInfo.processInfo.environment["SystemDrive"] ?? "C:" }

    static var programFilesX86: String {
        ProcessInfo.processInfo.environment["ProgramFiles(x86)"] ?? "\(systemDrive)\\Program Files (x86)"
    }

    static var windowsDir: String {
        ProcessInfo.processInfo.environment["windir"]
            ?? ProcessInfo.processInfo.environment["SystemRoot"]
            ?? "\(systemDrive)\\Windows"
    }

    static var system32: String { "\(windowsDir)\\System32" }
}