import XCTest
@testable import WebDriver
import Foundation

class Notepad {
    let session: Session
    init(winAppDriver: WinAppDriver, appArguments: [String]?, appWorkingDir: String?) {
        let windowsDir = ProcessInfo.processInfo.environment["SystemRoot"]!
        session = winAppDriver.newSession(app: "\(windowsDir)\\System32\\notepad.exe", 
            appArguments: appArguments, appWorkingDir: appWorkingDir)
    }

    func dismissNewFileDialog() {
        session.findElement(byName: "No")?.click()
    }

    func close() {
        session.findElement(byName: "close")?.click()
    }
}

class NotepadTest : XCTestCase {

    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    static var winAppDriver: WinAppDriver!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriver()
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        winAppDriver = nil
    }

    // Open notepad passing a new file name and a working directory as arguments and verify that notepad
    // is attempting to create a file by hitting the dismiss button in the confirmation dialog 
    // TODO: implement a way to check that notepad has the correct name and working directory
    // TODO: implement a way to confirm that the dialog was dismissed and notepad exited, 
    // e.g., by attempting to get the window handle from the session
    public func testDismissNewFileDialog() {
        let notepad = Notepad(winAppDriver: Self.winAppDriver, appArguments: [UUID().uuidString], appWorkingDir: NSTemporaryDirectory())
        Thread.sleep(forTimeInterval: 1)  // Needed until WIN-496
        notepad.dismissNewFileDialog()
    }
}
