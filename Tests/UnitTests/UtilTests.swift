import XCTest
@testable import WebDriver


class UtilsTests : XCTestCase {

    func testBuildArgString() {
        XCTAssertEqual(buildArgString(args: ["my dir\\file.txt"]), "\"my dir\\\\file.txt\"")
        XCTAssertEqual(buildArgString(args: ["my\tdir\\file.txt"]), "\"my\tdir\\\\file.txt\"")
        XCTAssertEqual(buildArgString(args: ["-m:\"description\""]), "-m:\\\"description\\\"")
        XCTAssertEqual(buildArgString(args: ["-m:\"commit description\""]), "\"-m:\\\"commit description\\\"\"")
        XCTAssertEqual(buildArgString(args: ["m:\"commit description\"", "my dir\\file.txt "]), "\"m:\\\"commit description\\\"\" \"my dir\\\\file.txt \"")
    }
}