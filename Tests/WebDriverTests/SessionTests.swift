import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {

    var webDriver: WebDriver!
    var session: Session!

    public override func setUp() {
        let winAppDriver = try! WinAppDriverProcess()
        webDriver = WebDriver(url: winAppDriver.url)
        session = webDriver.newSession(app: "C:\\Windows\\System32\\msinfo32.exe")
    }
    
    public func testTitle() {
        let title = session.title()
        XCTAssertEqual(title, "System Information")
    }

    public func testMaximizeAndMinimize() {
        let element = session.findElementByName("Maximize")
        element.click()
        element.click()
    }

    public override func tearDown() {
        webDriver.delete(session: session)        
    }
}