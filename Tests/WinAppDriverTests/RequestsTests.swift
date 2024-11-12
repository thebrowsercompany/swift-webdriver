import TestsCommon
@testable import WebDriver
@testable import WinAppDriver
import XCTest

class RequestsTests: XCTestCase {
    static var winAppDriver: Result<WinAppDriver, any Error>!

    override class func setUp() {
        winAppDriver = Result { try WinAppDriver.start() }
    }

    override class func tearDown() {
        winAppDriver = nil
    }

    var app: MSInfo32App!

    override func setUpWithError() throws {
        app = try MSInfo32App(winAppDriver: Self.winAppDriver.get())
    }

    override func tearDown() {
        app = nil
    }

    func testCanGetChildElements() throws {
        let children = try XCTUnwrap(app.listView.findElements(locator: .xpath("//ListItem")))
        XCTAssert(children.count > 0)
    }

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

    func testEnabled() throws {
        try XCTAssert(app.findWhatEditBox.enabled)
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
        try app.findWhatEditBox.sendKeys(.text(str, typingStrategy: .windowsKeyboardAgnostic))

        // Normally we should be able to read the text back immediately,
        // but the MSInfo32 "Find what" edit box seems to queue events
        // such that WinAppDriver returns before they are fully processed.
        struct UnexpectedText: Error { var text: String }
        _ = try poll(timeout: 0.5) {
            let text = try app.findWhatEditBox.text
            return text == str ? .success(()) : .failure(UnexpectedText(text: text))
        }
    }

    func testSendKeysWithAcceleratorsGivesFocus() throws {
        try app.session.sendKeys(MSInfo32App.findWhatEditBoxAccelerator)
        try XCTAssert(Self.hasKeyboardFocus(app.findWhatEditBox))
        try app.session.sendKeys(.tab)
        try XCTAssert(!Self.hasKeyboardFocus(app.findWhatEditBox))
    }

    func testSessionSendKeys_scopedModifiers() throws {
        try app.findWhatEditBox.click()
        try app.session.sendKeys(.sequence(.shift(.a), .a))
        XCTAssertEqual(try app.findWhatEditBox.text, "Aa")
    }

    func testSessionSendKeys_autoReleasedModifiers() throws {
        try app.findWhatEditBox.click()
        try app.session.sendKeys(.sequence(.shiftModifier, .a))
        try app.session.sendKeys(.a)
        XCTAssertEqual(try app.findWhatEditBox.text, "Aa")
    }

    func testSessionSendKeys_stickyModifiers() throws {
        try app.findWhatEditBox.click()
        try app.session.sendKeys(.sequence(.shiftModifier, .a), releaseModifiers: false)
        try app.session.sendKeys(.a)
        try app.session.sendKeys(.releaseModifiers)
        try app.session.sendKeys(.a)
        XCTAssertEqual(try app.findWhatEditBox.text, "AAa")
    }

    func testElementSendKeys_scopedModifiers() throws {
        try app.findWhatEditBox.sendKeys(.sequence(.shift(.a), .a))
        XCTAssertEqual(try app.findWhatEditBox.text, "Aa")
    }

    func testElementSendKeys_autoReleasedModifiers() throws {
        try app.findWhatEditBox.sendKeys(.sequence(.shiftModifier, .a))
        try app.findWhatEditBox.sendKeys(.a)
        XCTAssertEqual(try app.findWhatEditBox.text, "Aa")
    }

    private static func hasKeyboardFocus(_ element: Element) throws -> Bool {
        try XCTUnwrap(element.getAttribute(name: WinAppDriver.Attributes.hasKeyboardFocus)).lowercased() == "true"
    }
}
