@testable import WebDriver
import XCTest

class CommandLineTests: XCTestCase {
    func testbuildArgsString() {
        XCTAssertEqual(buildCommandLineArgsString(args: ["my dir\\file.txt"]), "\"my dir\\\\file.txt\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["my\tdir\\file.txt"]), "\"my\tdir\\\\file.txt\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["-m:\"description\""]), "-m:\\\"description\\\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["-m:\"commit description\""]), "\"-m:\\\"commit description\\\"\"")
        XCTAssertEqual(buildCommandLineArgsString(args: ["m:\"commit description\"", "my dir\\file.txt "]), "\"m:\\\"commit description\\\"\" \"my dir\\\\file.txt \"")
    }
}
