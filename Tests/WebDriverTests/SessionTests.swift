import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {

    // These statics are created before running any tests in this XCTestCase
    // and destroyed after all tests in this XCTestCase have been run
    static var winAppDriver: WinAppDriverProcess!
    static var webDriver: WebDriver!

    var session: Session!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriverProcess()
        webDriver = WebDriver(url: winAppDriver.url)
    }

    // Called before each test in this class
    public override func setUp() {
        session = Self.webDriver.newSession(app: "C:\\Windows\\System32\\msinfo32.exe")
    }

    // Called after each test in this class
    public override func tearDown() {
        // Force the destruction of the session
        session = nil
    }

    // Called after each test in this class
    public override class func tearDown() {
        // Force the destruction of the session
        webDriver = nil
        winAppDriver = nil
    }

    // Test methods

    public func testTitle() {
        let title = session.title
        XCTAssertEqual(title, "System Information")
    }

    public func testMaximizeAndRestore() {
        guard let element = session.findElement(byName: "Maximize") else {
            XCTAssert(false, "Maximize button not found")
            return
        } 
        element.click()
        element.click()
    }
}