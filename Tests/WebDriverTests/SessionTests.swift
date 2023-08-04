import TestsCommon
@testable import WebDriver
import XCTest

class SessionTests: XCTestCase {
    static var session: Session!
    static var setupError: Error?

    override public class func setUp() {
        do {
            // We don't store webDriver as session maintains a reference.
            let winAppDriver = try WinAppDriver()
            let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
            session = try winAppDriver.newSession(app: "\(windowsDir)\\System32\\msinfo32.exe")
        } catch {
            setupError = error
        }
    }

    override public func setUpWithError() throws {
        if let setupError = Self.setupError {
            throw setupError
        }
    }

    override public class func tearDown() {
        session = nil
    }

    // Test methods

    public func testTitle() throws {
        let title = try Self.session.title
        XCTAssertEqual(title, "System Information")
    }

    public func testScreenshot() throws {
        let data: Data = try Self.session.makePNGScreenshot()
        XCTAssert(isPNG(data: data))
    }

    public func testMaximizeAndRestore() throws {
        guard let element = try Self.session.findElement(byName: "Maximize") else {
            XCTAssert(false, "Maximize button not found")
            return
        }
        try element.click()
        try element.click()
    }
}
