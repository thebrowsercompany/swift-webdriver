import class Foundation.ProcessInfo

var system32DirectoryPath: String {
    let windowsDirectoryPath = ProcessInfo.processInfo.environment["windir"]
        ?? ProcessInfo.processInfo.environment["SystemRoot"]
        ?? (ProcessInfo.processInfo.environment["SystemDrive"] ?? "C:") + "\\Windows"
    return "\(windowsDirectoryPath)\\System32"
}