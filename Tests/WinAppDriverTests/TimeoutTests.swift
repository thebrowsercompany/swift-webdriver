@testable import WebDriver
import XCTest

class TimeoutTests: XCTestCase {
    private static var _winAppDriver: Result<WinAppDriver, any Error>!
    var winAppDriver: WinAppDriver! { try? Self._winAppDriver.get() }

    override class func setUp() {
        _winAppDriver = Result { try WinAppDriver.start() }
    }

    override class func tearDown() {
        _winAppDriver = nil
    }

    override func setUpWithError() throws {
        try XCTSkipIf(winAppDriver == nil)
    }

    func startApp() throws -> Session {
        // Use a simple app in which we can expect queries to execute quickly
        let capabilities = WinAppDriver.Capabilities.startApp(
            name: "\(WindowsSystemPaths.system32)\\winver.exe")
        return try Session(webDriver: winAppDriver, desiredCapabilities: capabilities)
    }

    static func time(_ callback: () throws -> Void) rethrows -> Double {
        let before = DispatchTime.now()
        try callback()
        let after = DispatchTime.now()
        return Double(after.uptimeNanoseconds - before.uptimeNanoseconds) / 1_000_000_000
    }

    public func testLibraryImplicitWait() throws {
        let session = try startApp()

        // Test library timeout implementation
        session.defaultRetryTimeout = 1
        XCTAssert(try Self.time({ _ = try session.findElement(byAccessibilityId: "IdThatDoesNotExist") }) > 0.5)

        session.defaultRetryTimeout = 0
        XCTAssert(try Self.time({ _ = try session.findElement(byAccessibilityId: "IdThatDoesNotExist") }) < 0.5)
    }

    public func testWebDriverImplicitWait() throws {
        let session = try startApp()
        session.defaultRetryTimeout = 0

        try session.setTimeout(type: TimeoutType.implicitWait, duration: 1)
        XCTAssert(try Self.time({ _ = try session.findElement(byAccessibilityId: "IdThatDoesNotExist") }) > 0.5)

        try session.setTimeout(type: TimeoutType.implicitWait, duration: 0)
        XCTAssert(try Self.time({ _ = try session.findElement(byAccessibilityId: "IdThatDoesNotExist") }) < 0.5)
    }
}
