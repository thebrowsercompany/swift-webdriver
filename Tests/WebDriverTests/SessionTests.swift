import TestsCommon
@testable import WebDriver
import XCTest

class SessionTests: XCTestCase {
    enum AccessibilityIds {
        static let searchSelectedCategoryOnlyCheckbox = "206"
    }

    static var session: Session!
    static var setupError: Error?

    override public class func setUp() {
        do {
            // We don't store webDriver as session maintains a reference.
            let winAppDriver = try WinAppDriver.start()
            let capabilities = WinAppDriver.Capabilities.startApp(
                name: "\(WindowsSystemPaths.system32)\\msinfo32.exe")
            session = try Session(webDriver: winAppDriver, desiredCapabilities: capabilities, requiredCapabilities: capabilities)
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
        let data: Data = try Self.session.screenshot()
        XCTAssert(isPNG(data: data))
    }

    public func testMaximizeAndRestore() throws {
        let element = try XCTUnwrap(Self.session.findElement(byName: "Maximize"), "Maximize button not found")
        try element.click()
        try element.click()
    }

    public func testAttributes() throws {
        let element = try XCTUnwrap(Self.session.findElement(byAccessibilityId: AccessibilityIds.searchSelectedCategoryOnlyCheckbox))
        try XCTAssertEqual(element.getAttribute(name: "HasKeyboardFocus").lowercased(), "false")

        try element.click()
        try XCTAssertEqual(element.getAttribute(name: "HasKeyboardFocus").lowercased(), "true")
    }
}
