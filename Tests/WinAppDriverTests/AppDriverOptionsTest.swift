import TestsCommon
import WinSDK
import XCTest

@testable import WebDriver
@testable import WinAppDriver

class AppDriverOptionsTest: XCTestCase {
    func tempFileName() -> String {
        return FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("txt").path
    }

    /// Tests that redirecting stdout to a file works.
    func testStdoutRedirectToFile() throws {
        let outputFile = try {
            // Start a new instance of msinfo32 and write the output to a file.
            let outputFile = tempFileName()
            let _ = try MSInfo32App(
                winAppDriver: WinAppDriver.start(
                    outputFile: outputFile
                ))
            return outputFile
        }()

        // Read the output file.
        let output = try String(contentsOfFile: outputFile, encoding: .utf16LittleEndian)

        // Delete the file.
        try FileManager.default.removeItem(atPath: outputFile)

        XCTAssert(output.contains("msinfo32"))
    }
}
