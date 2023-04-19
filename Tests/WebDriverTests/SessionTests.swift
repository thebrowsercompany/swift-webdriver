import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {

    static var webDriver: WebDriver!
    var session: Session!

    // Executed once before all the tests in this class
    public override class func setUp() {
        let winAppDriver = try! WinAppDriverProcess()
        webDriver = WebDriver(url: winAppDriver.url)
    }

    // Executed before each test in this class
    public override func setUp() {
        session = Self.webDriver.newSession(app: "C:\\Windows\\System32\\msinfo32.exe")
    }

    // Executed after each test in this class
    public override func tearDown() {
        // Force the destruction of the session
        session = nil
    }

    // Test methods

    public func testTitle() {
        let title = session.title
        XCTAssertEqual(title, "System Information")
    }

    public func testMaximizeAndMinimize() {
        guard let element = session.findElementByName("Maximize") else {
            XCTAssert(false, "Maximize button not found")
            return
        } 
        element.click()
        element.click()
    }
}