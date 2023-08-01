@testable import WebDriver
import XCTest

class StatusTest: XCTestCase {
    static var winAppDriver: WinAppDriver!

    override public class func setUp() {
        winAppDriver = try! WinAppDriver()
    }

    override public class func tearDown() {
        winAppDriver = nil
    }

    // test that status returns reasonable answers
    func testStatus() {
        let status = try! Self.winAppDriver.status

        // Check that we got a version number
        XCTAssert(status?.build?.version != nil)
        XCTAssert(status?.build?.version != String())

        // Check the returned date format
        if let dateString = status?.build?.time {
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
