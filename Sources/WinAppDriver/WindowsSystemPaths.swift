import WinSDK

enum WindowsSystemPaths {
    // Prefer a fallback to bubbling errors since consuming code
    // use these values as constants to build larger paths
    // and will handle failures at the time of accessing the file system.

    static let programFilesX86: String = getKnownFolderPath(CSIDL_PROGRAM_FILESX86, fallback: "C:\\Program Files (x86)")
    static let windowsDir: String = getKnownFolderPath(CSIDL_WINDOWS, fallback: "C:\\Windows")
    static let system32: String = getKnownFolderPath(CSIDL_SYSTEM, fallback: "\(windowsDir)\\System32")

    private static func getKnownFolderPath(_ folderId: Int32, fallback: String) -> String {
        (try? getKnownFolderPath(folderId)) ?? fallback
    }

    public static func getKnownFolderPath(_ folderID: Int32) throws -> String {
        var path = [WCHAR](repeating: 0, count: Int(MAX_PATH + 1))
        // We can't call SHGetKnownFolderPath due to the changing signature
        // of KNOWNFOLDERID between C and C++ interop.
        // Safe to revert when https://github.com/apple/swift/issues/69157 is fixed.
        let result = WinSDK.SHGetFolderPathW(nil, folderID, nil, 0, &path)
        guard result == S_OK else {
            throw Win32Error.getLastError(apiName: "SHGetFolderPath")
        }
        return String(decodingCString: path, as: UTF16.self)
    }
}
