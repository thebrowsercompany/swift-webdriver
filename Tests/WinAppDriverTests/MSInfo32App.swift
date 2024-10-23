@testable import WinAppDriver
import XCTest

class MSInfo32App {
    static let findWhatEditBoxAccelerator = Keys.alt(Keys.w)
    static let searchSelectedCategoryOnlyCheckboxAccelerator = Keys.alt(Keys.s)

    let session: Session

    init(winAppDriver: WinAppDriver) throws {
        let capabilities = WinAppDriver.Capabilities.startApp(name: "\(WindowsSystemPaths.system32)\\msinfo32.exe")
        session = try Session(webDriver: winAppDriver, desiredCapabilities: capabilities, requiredCapabilities: capabilities)
    }

    private lazy var _maximizeButton = Result {
        try session.findElement(locator: .name("Maximize"))
    }
    var maximizeButton: Element {
        get throws { try _maximizeButton.get() }
    }

    private lazy var _systemSummaryTree = Result {
        try session.findElement(locator: .accessibilityId("201"))
    }
    var systemSummaryTree: Element {
        get throws { try _systemSummaryTree.get() }
    }

    private lazy var _findWhatEditBox = Result {
        try session.findElement(locator: .accessibilityId("204"))
    }
    var findWhatEditBox: Element {
        get throws { try _findWhatEditBox.get() }
    }

    private lazy var _searchSelectedCategoryOnlyCheckbox = Result {
        try session.findElement(locator: .accessibilityId("206"))
    }
    var searchSelectedCategoryOnlyCheckbox: Element {
        get throws { try _searchSelectedCategoryOnlyCheckbox.get() }
    }

    private lazy var _listView = Result {
        let elements = try XCTUnwrap(session.findElements(locator: .accessibilityId("202")), "List view not found")
        try XCTSkipIf(elements.count != 1, "Expected exactly one list view; request timeout?")
        return elements[0]
    }
    var listView: Element {
        get throws { try _listView.get() }
    }
}
