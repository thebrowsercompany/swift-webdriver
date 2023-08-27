import Foundation
import WinSDK

extension WinAppDriver {
    /// newSession(app:) - Creates a new WinAppDriver session
    /// - app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch
    /// - appWorkingDir: working directory to run the app in
    /// - waitForAppLaunch: time to wait to the app to launch in seconds, 0 by default
    /// - Returns: new Session instance
    public func newSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil, waitForAppLaunch: Int? = nil) throws -> Session {
        let capabilities = ExtensionCapabilities()
        capabilities.app = app
        capabilities.appArguments = appArguments?.joined(separator: " ")
        capabilities.appWorkingDir = appWorkingDir
        capabilities.waitForAppLaunch = waitForAppLaunch
        let request = NewSessionRequest(desiredCapabilities: capabilities)
        let response = try send(request)
        return Session(in: self, id: response.sessionId, capabilities: response.value)
    }

    /// newSession(appTopLevelWindowHandle:)
    /// Creates a new session attached to an existing app top level window
    /// - Parameter appTopLevelWindowHandle: the window handle
    /// - Returns: new Session instance
    public func newSession(appTopLevelWindowHandle: UInt) throws -> Session {
        let capabilities = ExtensionCapabilities()
        capabilities.appTopLevelWindow = String(appTopLevelWindowHandle, radix: 16)
        let request = NewSessionRequest(desiredCapabilities: capabilities)
        let response = try send(request)
        return Session(in: self, id: try response.sessionId, capabilities: response.value)
    }
}
