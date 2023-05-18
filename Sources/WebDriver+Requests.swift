import Foundation
import WinSDK

extension WebDriver {
    /// newSession(app:) - Creates a new WinAppDriver session
    /// - Parameter app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch 
    /// - appWorkingDir: working directory to run the app in
    /// - Returns: new Session instance
    public func newSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil, waitForAppLaunch: Int? = nil) -> Session {
            let args = appArguments?.joined(separator: " ")
            let newSessionRequest = NewSessionRequest(app: app, appArguments: args, appWorkingDir: appWorkingDir, waitForAppLaunch: waitForAppLaunch)
            return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    /// newAttachedSession(app:)
    /// Starts the app directly and attach a new session to its window
    /// - Parameters:
    /// - Parameter app: location of the exe for the app to test
    /// - appArguments: Array of arguments to pass to the app on launch 
    /// - appWorkingDir: working directory to run the app in
    /// - Returns: new Session instance
    public func newAttachedSession(app: String, appArguments: [String]? = nil, appWorkingDir: String? = nil) -> Session {
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
        
        // From a desktop session, find the app top level window element
        // repeating up to 5 times for slow launches
        let desktopSession = newSession(app: "Root")
        var arcWindow: Element? = nil
        var count = 0
        while count < 5 && arcWindow == nil {
            count += 1
            arcWindow = desktopSession.findElement(byName: "Arc")
            if arcWindow == nil {
                // TODO: Sleep might noe be necessary, findElement already waits some
                Thread.sleep(forTimeInterval: 1)
            }
        }
        if arcWindow == nil {
            fatalError("Application window not found!")
        }

        // Attach a new session to the app window
        let session = newSession(appTopLevelWindowElement: arcWindow!)
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

        struct RequiredCapabilities : Encodable {
        }

        struct DesiredCapabilities : Encodable {
            var app: String?
            var appArguments: String?
            var appWorkingDir: String?
            var waitForAppLaunch: Int?
            let experimentalWebdriver = true
            enum CodingKeys: String, CodingKey {
                case app
                case appArguments
                case appWorkingDir
                case waitForAppLaunch = "ms:waitForAppLaunch"
                case experimentalWebdriver = "ms:experimental-webdriver"
            }
        }

        struct Body : Encodable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }

    /// newSession(appTopLevelWindowElement:)
    /// Creates a new session attached to an existing app top level window
    /// - Parameter appTopLevelWindowElement: the Element representing that window
    /// - Returns: new Session instance
    public func newSession(appTopLevelWindowElement: Element) -> Session {
            let newSessionRequest = NewSessionAttachRequest(appTopLevelWindowElement: appTopLevelWindowElement)
            return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    /// newSession(appTopLevelWindowHandle:)
    /// Creates a new session attached to an existing app top level window
    /// - Parameter appTopLevelWindowHandle: the window handle
    /// - Returns: new Session instance
    public func newSession(appTopLevelWindowHandle: UInt32) -> Session {
            let newSessionRequest = NewSessionAttachRequest(appTopLevelWindowHandle: appTopLevelWindowHandle)
            return Session(in: self, id: try! send(newSessionRequest).sessionId!)
    }

    struct NewSessionAttachRequest : WebDriverRequest {
        typealias ResponseValue = WebDriverNoResponseValue

        init(appTopLevelWindowHandle: UInt32) {
            let appTopLevelWindowHexHandle = String(appTopLevelWindowHandle, radix: 16)
            body.desiredCapabilities = .init(appTopLevelWindowHexHandle: appTopLevelWindowHexHandle)
        }

        init(appTopLevelWindowElement: Element) {
            let appTopLevelWindowHandle = appTopLevelWindowElement.getAttribute(name: "NativeWindowHandle")
            let appTopLevelWindowHexHandle = String(UInt32(appTopLevelWindowHandle) ?? 0, radix: 16)
            body.desiredCapabilities = .init(appTopLevelWindowHexHandle: appTopLevelWindowHexHandle)
        }

        var pathComponents: [String] { ["session"] }
        var method: HTTPMethod { .post }
        var body: Body = .init()

        struct RequiredCapabilities : Encodable {
        }

        struct DesiredCapabilities : Encodable {
            var appTopLevelWindowHexHandle: String?
            enum CodingKeys: String, CodingKey {
                case appTopLevelWindowHexHandle = "appTopLevelWindow"
            }
        }

        struct Body : Encodable {
            var requiredCapabilities: RequiredCapabilities?
            var desiredCapabilities: DesiredCapabilities = .init()
        }
    }
}