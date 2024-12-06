import Foundation

/// Chromium-specific capabilities for WebDriver sessions.
public class ChromiumCapabilities: Capabilities {
    /// Path to the Chromium executable. If not provided, the system will attempt to find it.
    public var binary: String?
    
    /// Launches Chromium in headless mode (no UI)
    public var headless: Bool?
    
    /// Chromium command-line arguments
    public var args: [String]?
    
    /// A list of extensions to install on browser startup
    public var extensions: [String]?
    
    /// Directory to use as user profile
    public var userDataDir: String?
    
    /// Proxy settings
    public var proxy: Proxy?
    
    /// Whether to disable web security features
    public var disableWebSecurity: Bool?
    
    /// Whether to ignore certificate errors
    public var ignoreCertificateErrors: Bool?
    
    public override init() {
        super.init()
    }
    
    private enum CodingKeys: String, CodingKey {
        case binary
        case headless
        case args
        case extensions
        case userDataDir
        case proxy
        case disableWebSecurity
        case ignoreCertificateErrors
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.binary = try container.decodeIfPresent(String.self, forKey: .binary)
        self.headless = try container.decodeIfPresent(Bool.self, forKey: .headless)
        self.args = try container.decodeIfPresent([String].self, forKey: .args)
        self.extensions = try container.decodeIfPresent([String].self, forKey: .extensions)
        self.userDataDir = try container.decodeIfPresent(String.self, forKey: .userDataDir)
        self.proxy = try container.decodeIfPresent(Proxy.self, forKey: .proxy)
        self.disableWebSecurity = try container.decodeIfPresent(Bool.self, forKey: .disableWebSecurity)
        self.ignoreCertificateErrors = try container.decodeIfPresent(Bool.self, forKey: .ignoreCertificateErrors)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(binary, forKey: .binary)
        try container.encodeIfPresent(headless, forKey: .headless)
        try container.encodeIfPresent(args, forKey: .args)
        try container.encodeIfPresent(extensions, forKey: .extensions)
        try container.encodeIfPresent(userDataDir, forKey: .userDataDir)
        try container.encodeIfPresent(proxy, forKey: .proxy)
        try container.encodeIfPresent(disableWebSecurity, forKey: .disableWebSecurity)
        try container.encodeIfPresent(ignoreCertificateErrors, forKey: .ignoreCertificateErrors)
        
        try super.encode(to: encoder)
    }
    
    /// Proxy configuration for Chromium
    public struct Proxy: Codable {
        public var proxyType: ProxyType
        public var httpProxy: String?
        public var sslProxy: String?
        public var ftpProxy: String?
        public var noProxy: [String]?
        
        public enum ProxyType: String, Codable {
            case direct = "direct"
            case manual = "manual"
            case pac = "pac"
            case autodetect = "autodetect"
            case system = "system"
        }
        
        public init(proxyType: ProxyType) {
            self.proxyType = proxyType
        }
    }
} 