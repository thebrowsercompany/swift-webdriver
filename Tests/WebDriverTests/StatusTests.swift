@testable import WebDriver
import XCTest

class StatusTest: XCTestCase {
    static var winAppDriver: WinAppDriver!
    static var setupError: Error?

    override public class func setUp() {
        do {
            winAppDriver = try WinAppDriver()
        } catch {
            setupError = error
        }
    }

    override public func setUpWithError() throws {
        if let setupError = Self.setupError {
            throw setupError
        }
    }

    override public class func tearDown() {
        winAppDriver = nil
    }

    // test that status returns reasonable answers
    func testStatus() throws {
        let status = try XCTUnwrap(Self.winAppDriver.status)

        // Check that we got a version number
        XCTAssertNotNil(status.build?.version)
        XCTAssertNotEqual(status.build?.version, String())

        // Check the returned date format
        if let dateString = status.build?.time {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss yyyy"
            let date = dateFormatter.date(from: dateString)
            XCTAssert(date != nil)
        }

        // and that the OS is windows
        XCTAssert(status.os?.name == "windows")
    }
}
