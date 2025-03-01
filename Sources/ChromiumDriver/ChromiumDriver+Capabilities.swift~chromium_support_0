//
//  ChromiumDriver+Capabilities.swift
//  swift-webdriver
//
//  Created by Астемир Бозиев on 01.03.2025.
//
import WebDriver

extension ChromiumDriver {

    public class Capabilities: BaseCapabilities {
        public var binary: String?
        public var headless: Bool?
        public var args: [String]?
        public var extensions: [String]?
        public var userDataDir: String?
        public var proxy: Proxy?
        public var disableWebSecurity: Bool?
        public var ignoreCertificateErrors: Bool?
        public var pageLoadStrategy: PageLoadStrategy?

        public override init() { super.init() }

        private enum CodingKeys: String, CodingKey {
            case binary
            case headless
            case args
            case extensions
            case userDataDir
            case proxy
            case disableWebSecurity
            case ignoreCertificateErrors
            case pageLoadStrategy
        }

        public required init(from decoder: Decoder) throws {
            try super.init(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.binary = try container.decodeIfPresent(String.self, forKey: .binary)
            self.headless = try container.decodeIfPresent(Bool.self, forKey: .headless)
            self.args = try container.decodeIfPresent([String].self, forKey: .args)
            self.extensions = try container.decodeIfPresent([String].self, forKey: .extensions)
            self.userDataDir = try container.decodeIfPresent(String.self, forKey: .userDataDir)
            self.proxy = try container.decodeIfPresent(Proxy.self, forKey: .proxy)
            self.disableWebSecurity = try container.decodeIfPresent(Bool.self, forKey: .disableWebSecurity)
            self.ignoreCertificateErrors = try container.decodeIfPresent(Bool.self, forKey: .ignoreCertificateErrors)
            self.pageLoadStrategy = try container.decodeIfPresent(PageLoadStrategy.self, forKey: .pageLoadStrategy)
        }

        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(binary, forKey: .binary)
            try container.encodeIfPresent(headless, forKey: .headless)
            try container.encodeIfPresent(args, forKey: .args)
            try container.encodeIfPresent(extensions, forKey: .extensions)
            try container.encodeIfPresent(userDataDir, forKey: .userDataDir)
            try container.encodeIfPresent(proxy, forKey: .proxy)
            try container.encodeIfPresent(disableWebSecurity, forKey: .disableWebSecurity)
            try container.encodeIfPresent(ignoreCertificateErrors, forKey: .ignoreCertificateErrors)
            try container.encodeIfPresent(pageLoadStrategy, forKey: .pageLoadStrategy)
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

        public enum PageLoadStrategy: String, Codable {
            case none
            case eager
            case normal
        }
    }
}
