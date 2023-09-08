import WinSDK

internal struct Win32Error: Error {
    public var apiName: String
    public var errorCode: UInt32

    internal static func getLastError(apiName: String) -> Self {
        Self(apiName: apiName, errorCode: GetLastError())
    }
}