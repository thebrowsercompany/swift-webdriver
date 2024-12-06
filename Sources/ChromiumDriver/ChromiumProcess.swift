import Foundation

/// Manages a Chromium browser process separate from ChromeDriver
public class ChromiumProcess {
    private var process: Process?
    private let chromiumPath: String
    private let arguments: [String]
    
    /// Creates a ChromiumProcess instance
    /// - Parameters:
    ///   - path: Path to the Chromium executable
    ///   - arguments: Command-line arguments for Chromium
    public init(path: String? = nil, arguments: [String] = []) throws {
        // Find Chromium if path not provided
        if let path = path {
            self.chromiumPath = path
        } else if let foundPath = ChromiumDriver.findChromiumBrowser() {
            self.chromiumPath = foundPath
        } else {
            throw ChromiumDriverError.browserNotFound
        }
        
        self.arguments = arguments
    }
    
    /// Starts the Chromium browser process
    /// - Parameters:
    ///   - userDataDir: Directory for user profile
    ///   - headless: Whether to run in headless mode
    ///   - additionalArgs: Additional command-line arguments
    /// - Throws: Error if the browser cannot be started
    public func start(userDataDir: String? = nil, headless: Bool = false, additionalArgs: [String] = []) throws {
        guard process == nil else { return }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: chromiumPath)
        
        var args = self.arguments
        
        // Add standard arguments
        if headless {
            args.append("--headless")
        }
        
        if let userDataDir = userDataDir {
            args.append("--user-data-dir=\(userDataDir)")
        }
        
        // Remote debugging is required for CDP
        args.append("--remote-debugging-port=9222")
        
        // Add any additional arguments
        args.append(contentsOf: additionalArgs)
        
        process.arguments = args
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        self.process = process
    }
    
    /// Stops the Chromium browser process
    /// - Throws: Error if the browser cannot be stopped
    public func stop() throws {
        guard let process = process, process.isRunning else { return }
        process.terminate()
        self.process = nil
    }
    
    /// Checks if the Chromium process is running
    public var isRunning: Bool {
        guard let process = process else { return false }
        return process.isRunning
    }
    
    deinit {
        try? stop()
    }
} 