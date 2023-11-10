import struct Foundation.TimeInterval
import WebDriver

extension WinAppDriver {
    // See https://github.com/microsoft/WinAppDriver/blob/master/Docs/AuthoringTestScripts.md
    public class Capabilities: BaseCapabilities {
        public var app: String?
        public var appArguments: String?
        public var appTopLevelWindow: String?
        public var appWorkingDir: String?
        public var platformVersion: String?
        public var waitForAppLaunch: Int?
        public var experimentalWebDriver: Bool?

        public override init() { super.init() }

        public static func startApp(name: String, arguments: [String] = [], workingDir: String? = nil, waitTime: TimeInterval? = nil) -> Capabilities {
            let caps = Capabilities()
            caps.app = name
            caps.appArguments = arguments.isEmpty ? nil : buildCommandLineArgsString(args: arguments)
            caps.appWorkingDir = workingDir
            if let waitTime { caps.waitForAppLaunch = Int(waitTime * 1000) }
            return caps
        }

        public static func attachToApp(topLevelWindowHandle: UInt) -> Capabilities {
            let caps = Capabilities()
            caps.appTopLevelWindow = String(topLevelWindowHandle, radix: 16)
            return caps
        }

        public static func attachToDesktop() -> Capabilities {
            let caps = Capabilities()
            caps.app = "Root"
            return caps
        }

        // Swift can't synthesize init(from:) for subclasses of Codable classes
        public required init(from decoder: Decoder) throws {
            try super.init(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            app = try? container.decodeIfPresent(String.self, forKey: .app)
            appArguments = try? container.decodeIfPresent(String.self, forKey: .appArguments)
            appTopLevelWindow = try? container.decodeIfPresent(String.self, forKey: .appTopLevelWindow)
            appWorkingDir = try? container.decodeIfPresent(String.self, forKey: .appWorkingDir)
            platformVersion = try? container.decodeIfPresent(String.self, forKey: .platformVersion)
            waitForAppLaunch = try? container.decodeIfPresent(Int.self, forKey: .waitForAppLaunch)
            experimentalWebDriver = try? container.decodeIfPresent(Bool.self, forKey: .experimentalWebDriver)
        }

        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(app, forKey: .app)
            try container.encodeIfPresent(appArguments, forKey: .appArguments)
            try container.encodeIfPresent(appTopLevelWindow, forKey: .appTopLevelWindow)
            try container.encodeIfPresent(appWorkingDir, forKey: .appWorkingDir)
            try container.encodeIfPresent(platformVersion, forKey: .platformVersion)
            try container.encodeIfPresent(waitForAppLaunch, forKey: .waitForAppLaunch)
            try container.encodeIfPresent(experimentalWebDriver, forKey: .experimentalWebDriver)
        }

        private enum CodingKeys: String, CodingKey {
            case app
            case appArguments
            case appTopLevelWindow
            case appWorkingDir
            case platformVersion
            case waitForAppLaunch = "ms:waitForAppLaunch"
            case experimentalWebDriver = "ms:experimental-webdriver"
        }
    }
}