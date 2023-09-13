import WinSDK

enum WindowsSystemPaths {
    // Prefer a fallback to bubbling errors since consuming code
    // use these values as constants to build larger paths
    // and will handle failures at the time of accessing the file system.

    static let programFilesX86: String = getKnownFolderPath(FOLDERID_ProgramFilesX86, fallback: "C:\\Program Files (x86)")
    static let windowsDir: String = getKnownFolderPath(FOLDERID_Windows, fallback: "C:\\Windows")
    static let system32: String = getKnownFolderPath(FOLDERID_System, fallback: "\(windowsDir)\\System32")

    private static func getKnownFolderPath(_ folderId: KNOWNFOLDERID, fallback: String) -> String {
        (try? getKnownFolderPath(folderId)) ?? fallback
    }

    private static func getKnownFolderPath(_ folderId: KNOWNFOLDERID) throws -> String {
        var mutableId = folderId
        var path: PWSTR?
        let result = WinSDK.SHGetKnownFolderPath(&mutableId, 0, nil, &path)
        defer { WinSDK.CoTaskMemFree(pszPath) } // no-op on null
        guard let path, result == S_OK else {
           throw Win32Error.getLastError(apiName: "SHGetKnownFolderPath") 
        }
        return String(decodingCString: path, as: UTF16.self)
    }
}
