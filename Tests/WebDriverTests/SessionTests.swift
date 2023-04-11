import XCTest
@testable import WebDriver

class SessionTests : XCTestCase {
    public func testTitle() {
        let winAppDriver = try! WinAppDriverProcess()
        let webDriver = WebDriver(url: winAppDriver.url)

        let session = webDriver.NewSession(app: "C:\\Windows\\System32\\msinfo32.exe")
        
        let title = session.Title()
        XCTAssertEqual(title, "System Information")
        
        let element = session.FindElementByName("Maximize")
        element.click()
        element.click()

        webDriver.Delete(session: session)        
    }
}