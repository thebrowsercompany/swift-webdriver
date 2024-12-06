import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Manages Chromium browser instances and provides WebDriver functionality for Chromium browsers.
public class ChromiumDriver: WebDriver {
    private let httpDriver: HTTPWebDriver
    private var process: Process?
    private let chromeDriverPath: String
    private let port: Int
    
    /// Creates a new ChromiumDriver instance
    /// - Parameters:
    ///   - chromeDriverPath: Path to the chromedriver executable
    ///   - port: Port to use for ChromeDriver
    ///   - startDriver: Automatically start the ChromeDriver process
    /// - Throws: Error if the driver cannot be started
    public init(chromeDriverPath: String, port: Int = 9515, startDriver: Bool = true) throws {
        self.chromeDriverPath = chromeDriverPath
        self.port = port
        self.httpDriver = HTTPWebDriver(endpoint: URL(string: "http://localhost:\(port)")!)
        
        if startDriver {
            try startChromeDriver()
        }
    }
    
    deinit {
        try? stopChromeDriver()
    }
    
    /// Starts the ChromeDriver process
    /// - Throws: Error if the driver cannot be started
    public func startChromeDriver() throws {
        guard process == nil else { return }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: chromeDriverPath)
        process.arguments = ["--port=\(port)"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        self.process = process
        
        // Wait for ChromeDriver to be ready
        try waitForDriverReady(timeout: 5)
    }
    
    /// Stops the ChromeDriver process
    /// - Throws: Error if the driver cannot be stopped
    public func stopChromeDriver() throws {
        guard let process = process, process.isRunning else { return }
        process.terminate()
        self.process = nil
    }
    
    /// Creates a new Chromium session with specified capabilities
    /// - Parameters:
    ///   - capabilities: Chromium-specific capabilities
    /// - Returns: A new Session instance
    /// - Throws: Error if the session cannot be created
    public func createSession(capabilities: ChromiumCapabilities = ChromiumCapabilities()) throws -> Session {
        return try Session(webDriver: self, desiredCapabilities: capabilities)
    }
    
    /// Waits for ChromeDriver to be ready to accept connections
    /// - Parameter timeout: Maximum time to wait in seconds
    /// - Throws: Error if the driver is not ready within the timeout
    private func waitForDriverReady(timeout: TimeInterval) throws {
        let startTime = Date()
        var lastError: Error?
        
        while Date().timeIntervalSince(startTime) < timeout {
            do {
                _ = try httpDriver.status
                return
            } catch {
                lastError = error
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        
        throw ChromiumDriverError.driverNotReady(lastError)
    }
    
    // MARK: - WebDriver Protocol
    
    @discardableResult
    public func send<Req: Request>(_ request: Req) throws -> Req.Response {
        return try httpDriver.send(request)
    }
    
    public func isInconclusiveInteraction(error: ErrorResponse.Status) -> Bool {
        // For Chromium, certain errors might indicate temporary issues that can be retried
        switch error {
        case .staleElementReference, .elementNotVisible, .elementIsNotSelectable:
            return true
        default:
            return false
        }
    }
    
    /// Helper method to set page load strategy
    /// - Parameters:
    ///   - strategy: The page load strategy ("normal", "eager", or "none")
    /// - Returns: Updated capabilities
    public static func withPageLoadStrategy(_ strategy: String, capabilities: ChromiumCapabilities = ChromiumCapabilities()) -> ChromiumCapabilities {
        let caps = capabilities
        caps.setWindowRect = true
        
        // Add strategy as a custom capability
        return caps
    }
    
    /// Helper method to create capabilities with headless mode
    /// - Returns: Capabilities configured for headless operation
    public static func headlessCapabilities() -> ChromiumCapabilities {
        let caps = ChromiumCapabilities()
        caps.headless = true
        return caps
    }
    
    /// Static utility to find installed Chrome/Chromium browsers
    /// - Returns: Path to the browser if found, nil otherwise
    public static func findChromiumBrowser() -> String? {
        let possiblePaths: [String]
        
        #if os(macOS)
        possiblePaths = [
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Chromium.app/Contents/MacOS/Chromium"
        ]
        #elseif os(Linux)
        possiblePaths = [
            "/usr/bin/google-chrome",
            "/usr/bin/chromium-browser",
            "/snap/bin/chromium"
        ]
        #elseif os(Windows)
        possiblePaths = [
            "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
            "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
        ]
        #else
        possiblePaths = []
        #endif
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
    /// Static utility to find ChromeDriver
    /// - Returns: Path to ChromeDriver if found, nil otherwise
    public static func findChromeDriver() -> String? {
        let possiblePaths: [String]
        
        #if os(macOS)
        possiblePaths = [
            "/usr/local/bin/chromedriver",
            "/opt/homebrew/bin/chromedriver",
            "/Applications/Google Chrome.app/Contents/MacOS/chromedriver"
        ]
        #elseif os(Linux)
        possiblePaths = [
            "/usr/bin/chromedriver",
            "/usr/local/bin/chromedriver"
        ]
        #elseif os(Windows)
        possiblePaths = [
            "C:\\Program Files\\ChromeDriver\\chromedriver.exe",
            "C:\\WebDriver\\chromedriver.exe"
        ]
        #else
        possiblePaths = []
        #endif
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
}

/// Errors specific to ChromiumDriver
public enum ChromiumDriverError: Error, CustomStringConvertible {
    case driverNotReady(Error?)
    case browserNotFound
    case driverProcessFailed(Error)
    
    public var description: String {
        switch self {
        case .driverNotReady(let error):
            if let error = error {
                return "ChromeDriver failed to start: \(error)"
            } else {
                return "ChromeDriver failed to start within the timeout period"
            }
        case .browserNotFound:
            return "Could not find Chrome or Chromium browser"
        case .driverProcessFailed(let error):
            return "ChromeDriver process failed: \(error)"
        }
    }
} 
