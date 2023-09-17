@testable import WebDriver
import XCTest

class MSInfo32App {
    static let findWhatEditBoxAccelerator = Keys.alt(Keys.w)
    static let searchSelectedCategoryOnlyCheckboxAccelerator = Keys.alt(Keys.s)

    let session: Session

    init(winAppDriver: WinAppDriver) throws {
        print("\(Date()) MSInfo32App.init enter")
        let capabilities = WinAppDriver.Capabilities.startApp(name: "\(WindowsSystemPaths.system32)\\msinfo32.exe")
        session = try Session(webDriver: winAppDriver, desiredCapabilities: capabilities, requiredCapabilities: capabilities)
        print("\(Date()) MSInfo32App.init exit")
    }

    private lazy var _maximizeButton = Result {
        try XCTUnwrap(session.findElement(byName: "Maximize"), "Maximize button not found")
    }
    var maximizeButton: Element {
        get throws { try _maximizeButton.get() }
    }

    private lazy var _systemSummaryTree = Result {
        try XCTUnwrap(session.findElement(byAccessibilityId: "201"), "System summary tree control not found")
    }
    var systemSummaryTree: Element {
        get throws { try _systemSummaryTree.get() }
    }

    private lazy var _findWhatEditBox = Result {
        try XCTUnwrap(session.findElement(byAccessibilityId: "204"), "'Find what' edit box not found")
    }
    var findWhatEditBox: Element {
        get throws { try _findWhatEditBox.get() }
    }

    private lazy var _searchSelectedCategoryOnlyCheckbox = Result {
        try XCTUnwrap(session.findElement(byAccessibilityId: "206"), "'Search selected category only' checkbox not found")
    }
    var searchSelectedCategoryOnlyCheckbox: Element {
        get throws { try _searchSelectedCategoryOnlyCheckbox.get() }
    }
}