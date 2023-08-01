import TestsCommon
@testable import WebDriver
import XCTest

class SessionTests: XCTestCase {
    static var session: Session!

    override public class func setUp() {
        let winAppDriver = try! WinAppDriver()

        // We don't store webDriver as session maintains a reference.
        let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
        session = winAppDriver.newSession(app: "\(windowsDir)\\System32\\msinfo32.exe")
    }

    override public class func tearDown() {
        session = nil
    }

    // Test methods

    public func testTitle() {
        let title = Self.session.title
        XCTAssertEqual(title, "System Information")
    }

    public func testScreenshot() {
        let data: Data = Self.session.makePNGScreenshot()
        XCTAssert(isPNG(data: data))
    }

    public func testMaximizeAndRestore() {
        guard let element = Self.session.findElement(byName: "Maximize") else {
            XCTAssert(false, "Maximize button not found")
            return
        }
        element.click()
        element.click()
    }
}
