@testable import WinAppDriver
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
        if case .failure(let error) = Self._winAppDriver {
            throw XCTSkip("Failed to start WinAppDriver: \(error)")
        }
    }

    func startApp() throws -> Session {
        // Use a simple app in which we can expect queries to execute quickly
        let capabilities = WinAppDriver.Capabilities.startApp(
            name: "\(WindowsSystemPaths.system32)\\winver.exe")
        return try Session(webDriver: winAppDriver, desiredCapabilities: capabilities)
    }

    static func measureTime(_ callback: () throws -> Void) rethrows -> Double {
        let before = DispatchTime.now()
        try callback()
        let after = DispatchTime.now()
        return Double(after.uptimeNanoseconds - before.uptimeNanoseconds) / 1_000_000_000
    }

    static func measureNoSuchElementTime(_ session: Session) -> Double {
        measureTime {
            XCTAssertThrowsError({
                try session.findElement(locator: .accessibilityId("IdThatDoesNotExist"))
            })
        }
    }

    public func testWebDriverImplicitWait() throws {
        let session = try startApp()

        session.implicitWaitTimeout = 1
        XCTAssertGreaterThan(Self.measureNoSuchElementTime(session), 0.5)

        session.implicitWaitTimeout = 0
        XCTAssertLessThan(Self.measureNoSuchElementTime(session), 0.5)

        XCTAssert(!session.emulateImplicitWait)
    }

    public func testEmulatedImplicitWait() throws {
        let session = try startApp()

        // Test library timeout implementation
        session.emulateImplicitWait = true
        session.implicitWaitTimeout = 1
        XCTAssertGreaterThan(Self.measureNoSuchElementTime(session), 0.5)

        session.implicitWaitTimeout = 0
        XCTAssertLessThan(Self.measureNoSuchElementTime(session), 0.5)
    }
}
