import XCTest
@testable import WebDriver

class StaticSessionTests : XCTestCase {

    static var webDriver: WebDriver!
    static let calculatorAppId = "C:\\Windows\\System32\\msinfo32.exe"
    static var session: Session!

    // Executed once before all the tests in this class
    public override class func setUp() {
        let winAppDriver = try! WinAppDriverProcess()
        webDriver = WebDriver(url: winAppDriver.url)
        session = webDriver.newSession(app: calculatorAppId)
    }

    // Executed once after all tests in this class have run
    public override class func tearDown() {
        // Force the destruction of the session
        session = nil
    }

    // Test methods

    public func testTitle() {
        let title = Self.session.title
        XCTAssertEqual(title, "System Information")
    }

    public func testMaximizeAndMinimize() {
        guard let element = Self.session.findElementByName("Maximize") else {
            XCTAssert(false, "Maximize button not found")
            return
        } 
        element.click()
        element.click()
    }
}