import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {

    static var session: Session!

    // Called once before all the tests in this class
    public override class func setUp() {
        // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test
        let winAppDriver = try! WinAppDriver()
        
        // We don't store webDriver as session maintains it alive
        let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
        session = winAppDriver.newSession(app: "\(windowsDir)\\System32\\msinfo32.exe")
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        // Force the destruction of the session
        session = nil
    }

    // Test methods

    public func testTitle() {
        let title = Self.session.title
        XCTAssertEqual(title, "System Information")
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