import Foundation
import WinSDK

extension WinAppDriver {
    /// newSession(app:) - Creates a new WinAppDriver session
    /// - app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch 
    /// - appWorkingDir: working directory to run the app in
    /// - waitForAppLaunch: time to wait to the app to launch in seconds, 0 by default
    /// - Returns: new Session instance
    public func newSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil, waitForAppLaunch: Int? = nil) -> Session {
            let args = appArguments?.joined(separator: " ")
            let newSessionRequest = NewSessionRequest(app: app, appArguments: args, appWorkingDir: appWorkingDir, waitForAppLaunch: waitForAppLaunch)
            return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    /// newAttachedSession(app:)
    /// Starts the app and attach a new session to its window
    /// - app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch 
    /// - appWorkingDir: working directory to run the app in
    /// - retryForTimeInterval: retries attaching for that time interval, in seconds, 5 by default
    /// - Returns: new Session instance
    public func newAttachedSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil, retryForTimeInterval: TimeInterval? = nil) -> Session {
        // Start the app process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: app)
        process.arguments = appArguments
        process.standardInput = nil
        process.standardOutput = nil
        do {
            try process.run()
        } catch {
            let args = appArguments?.joined(separator: " ")
            fatalError("Could not run: \(app) \(String(describing: args))")
        }
        
        var topLevelWindowHandle: HWND? = nil
        let start = Date.now
        let retryForTimeInterval = retryForTimeInterval ?? 5
        while topLevelWindowHandle == nil && Date.now < Date(timeInterval: retryForTimeInterval, since: start) {
            topLevelWindowHandle = findTopLevelWindow(for: process)
            if topLevelWindowHandle == nil {
                Thread.sleep(forTimeInterval: 1)
            }
        }
        if topLevelWindowHandle == nil {
            fatalError("Application window not found!")
        }

        let session = newSession(appTopLevelWindowHandle: UInt(bitPattern: topLevelWindowHandle))
        session.appProcess = process
        return session
    }

    struct NewSessionRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(app: String, appArguments: String?, appWorkingDir: String?, waitForAppLaunch: Int?) {
            body.desiredCapabilities = .init(app: app, appArguments: appArguments, appWorkingDir: appWorkingDir, waitForAppLaunch: waitForAppLaunch)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Codable {
        }

        struct DesiredCapabilities : Codable {
            var app: String?
            var appArguments: String?
            var appWorkingDir: String?
            var waitForAppLaunch: Int?
            let experimentalWebDriver = true
            enum CodingKeys: String, CodingKey {
                case app
                case appArguments
                case appWorkingDir
                case waitForAppLaunch = "ms:waitForAppLaunch"
                case experimentalWebDriver = "ms:experimental-webdriver"
            }
        }

        struct Body : Codable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }

    /// newSession(appTopLevelWindowHandle:)
    /// Creates a new session attached to an existing app top level window
    /// - Parameter appTopLevelWindowHandle: the window handle
    /// - Returns: new Session instance
    public func newSession(appTopLevelWindowHandle: UInt) -> Session {
            let newSessionRequest = NewSessionAttachRequest(appTopLevelWindowHandle: appTopLevelWindowHandle)
            return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    struct NewSessionAttachRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(appTopLevelWindowHandle: UInt) {
            let appTopLevelWindowHexHandle = String(appTopLevelWindowHandle, radix: 16)
            body.desiredCapabilities = .init(appTopLevelWindowHexHandle: appTopLevelWindowHexHandle)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Codable {
        }

        struct DesiredCapabilities : Codable {
            var appTopLevelWindowHexHandle: String?
            enum CodingKeys: String, CodingKey {
                case appTopLevelWindowHexHandle = "appTopLevelWindow"
            }
        }

        struct Body : Codable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }
}