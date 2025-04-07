import Foundation
import WebDriver
import XCTest

final class AppiumTests: XCTestCase {
    private var appiumServerURL: URL? = nil

    override func setUpWithError() throws {
        super.setUp()
        appiumServerURL = ProcessInfo.processInfo.environment["APPIUM_SERVER_URL"].flatMap { URL(string: $0) }
        try XCTSkipIf(appiumServerURL == nil, "APPIUM_SERVER_URL environment variable is not set.")
    }

#if os(Windows)
    func testAppium() throws {
        let webDriver = HTTPWebDriver(endpoint: appiumServerURL!, wireProtocol: .w3c)

        let appiumOptions = Capabilities.AppiumOptions()
        appiumOptions.automationName = "windows"
        appiumOptions.app = "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"

        let capabilities = Capabilities()
        capabilities.platformName = "windows"
        capabilities.appiumOptions = appiumOptions

        let session = try Session.createW3C(webDriver: webDriver, alwaysMatch: capabilities)
        try session.sendKeys(.alt(.f4))
    }
#endif
}