import TestsCommon
@testable import WebDriver
import XCTest

class RequestsTests: XCTestCase {
    static var _app: Result<MSInfo32App, any Error>!
    var app: MSInfo32App! { get { try? Self._app.get() } }

    override class func setUp() {
        _app = Result { try MSInfo32App(winAppDriver: WinAppDriver.start()) }
    }

    override func setUpWithError() throws {
        if case .failure(let error) = Self._app {
            throw XCTSkip("Failed to start test app: \(error)")
        }
    }

    override class func tearDown() { _app = nil }

    func testStatusReportsWinAppDriverOnWindows() throws {
        let status = try XCTUnwrap(app.session.webDriver.status)
        XCTAssertNotNil(status.build?.version)
        XCTAssert(status.os?.name == "windows")
    }

    func testSessionTitleReadsWindowTitle() throws {
        XCTAssertEqual(try app.session.title, "System Information")
    }

    func testElementSizeCanChange() throws {
        let oldSize = try app.systemSummaryTree.size
        try app.maximizeButton.click()
        let newSize = try app.systemSummaryTree.size
        try app.maximizeButton.click()
        XCTAssertNotEqual(oldSize.width, newSize.width)
        XCTAssertNotEqual(oldSize.height, newSize.height)
    }

    func testScreenshotReturnsPNG() throws {
        XCTAssert(isPNG(data: try app.session.screenshot()))
    }

    func testAttributes() throws {
        try XCTAssertEqual(app.findWhatEditBox.getAttribute(name: WinAppDriver.Attributes.className), "Edit")
    }

    func testElementClickGivesKeyboardFocus() throws {
        try app.systemSummaryTree.click()
        try XCTAssert(!Self.hasKeyboardFocus(app.findWhatEditBox))
        try app.findWhatEditBox.click()
        try XCTAssert(Self.hasKeyboardFocus(app.findWhatEditBox))
    }

    func testMouseMoveToElementPositionsCursorAccordingly() throws {
        try app.systemSummaryTree.click()
        try XCTAssert(!Self.hasKeyboardFocus(app.findWhatEditBox))
        let size = try app.findWhatEditBox.size
        try app.session.moveTo(element: app.findWhatEditBox, xOffset: size.width / 2, yOffset: size.height / 2)
        try app.session.click()
        try XCTAssert(Self.hasKeyboardFocus(app.findWhatEditBox))
    }

    func testSendKeysWithUnicodeCharacter() throws {
        // k: Requires no modifiers on a US Keyboard
        // K: Requires modifiers on a US Keyboard
        // ł: Not typeable on a US Keyboard
        // ☃: Unicode BMP character
        let str = "kKł☃"
        try app.findWhatEditBox.sendKeys(Keys.text(str, typingStrategy: .windowsKeyboardAgnostic))
        // Normally we should be able to read the text back immediately,
        // but the MSInfo32 "Find what" edit box seems to queue events
        // such that WinAppDriver returns before they are fully processed.
        XCTAssertEqual(
            try poll(timeout: 0.5) {
                let text = try app.findWhatEditBox.text
                return PollResult(value: text, success: text == str)
            }.value, str)
    }

    func testSendKeysWithAcceleratorsGivesFocus() throws {
        try app.session.sendKeys(MSInfo32App.findWhatEditBoxAccelerator)
        try XCTAssert(Self.hasKeyboardFocus(app.findWhatEditBox))
        try app.session.sendKeys(Keys.tab)
        try XCTAssert(!Self.hasKeyboardFocus(app.findWhatEditBox))
    }

    private static func hasKeyboardFocus(_ element: Element) throws -> Bool {
        try XCTUnwrap(element.getAttribute(name: WinAppDriver.Attributes.hasKeyboardFocus)).lowercased() == "true"
    }
}
