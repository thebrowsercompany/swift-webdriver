import XCTest
@testable import WebDriver

class StatusTest : XCTestCase {
    static var winAppDriver: WinAppDriver!

    // Called once before all the tests in this class
    public override class func setUp() {
        // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test
        winAppDriver = try! WinAppDriver()
    }

    // test that status returns reasonable answers
    func testStatus() {
        let status = try! Self.winAppDriver.status

        // Check that we got a version number
        XCTAssert(status?.build?.version != nil)
        XCTAssert(status?.build?.version != String())

        // Check the returned date format
        if let dateString = status?.build?.time  {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss yyyy"
            let date = dateFormatter.date(from: dateString) 
            XCTAssert(date != nil)
        }

        // and that the OS is windows
        XCTAssert(status?.os?.name == "windows")
    }
}
