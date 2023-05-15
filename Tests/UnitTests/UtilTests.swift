import XCTest
@testable import WebDriver


class UtilsTests : XCTestCase {

    func testbuildCommandLineArgsString() {
        XCTAssertEqual(buildCommandLineArgsString(args: ["my dir\\file.txt"]), "\"my dir\\\\file.txt\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["my\tdir\\file.txt"]), "\"my\tdir\\\\file.txt\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["-m:\"description\""]), "-m:\\\"description\\\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["-m:\"commit description\""]), "\"-m:\\\"commit description\\\"\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["m:\"commit description\"", "my dir\\file.txt "]), "\"m:\\\"commit description\\\"\" \"my dir\\\\file.txt \"")
    }
}