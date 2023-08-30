import WebDriver
import XCTest
import struct Foundation.URL

public class XCUIElement {

}

public class XCUIApplication {
    private let url: URL

    public var launchArguments: [String] = [] {
        willSet { precondition(session == nil) }
    }

    public var launchEnvironment: [String: String] = [:] {
        willSet { precondition(session == nil) }
    }

    private var session: Session?

    public init(url: URL) {
        self.url = url
    }

    public func launch() {
        precondition(session == nil)

        do {
            let driver = try WinAppDriver()
            session = try driver.newSession(app: url.absoluteString, appArguments: launchArguments)
        } catch {
            XCTFail()
        }
    }

    public func activate() {
        if session == nil { launch() }

    }

    func terminate() {
        do { try session?.delete() }
        catch { XCTFail() }
        session = nil
    }
}