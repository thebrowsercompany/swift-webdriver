import XCTest
@testable import WebDriver

class StaticSessionTests : XCTestCase {

    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    static var winAppDriver: WinAppDriverProcess!
    static var session: Session!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriverProcess()
        
        // We don't store webDriver as session maintains it alive
        let webDriver = WebDriver(url: winAppDriver.url)
        session = webDriver.newSession(app: "C:\\Windows\\System32\\msinfo32.exe")
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        // Force the destruction of the session
        session = nil
        winAppDriver = nil
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