import XCTest
@testable import WebDriver
import Foundation

class Notepad {
    let session: Session
    init(webDriver: WebDriver, appArguments: String?, appWorkingDir: String?) {
        session = webDriver.newSession(app: "C:\\Windows\\System32\\notepad.exe", 
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
    static var winAppDriver: WinAppDriverProcess!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriverProcess()
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
    public func testDismisNewFileDialog() {
        let webDriver = WebDriver(url: Self.winAppDriver.url)
        let notepad = Notepad(webDriver: webDriver, appArguments: UUID().uuidString, appWorkingDir: NSTemporaryDirectory())
        Thread.sleep(forTimeInterval: 1)
        notepad.dismissNewFileDialog()
    }
}
