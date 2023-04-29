import XCTest
@testable import WebDriver

class CalculatorTests : XCTestCase {

    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    // Use a single WinAppDriver process to avoid incurring the process start/end cost for every test    
    static var winAppDriver: WinAppDriverProcess!
    static var session: Session!

    // Called once before all the tests in this class
    public override class func setUp() {
        winAppDriver = try! WinAppDriverProcess()
        
        // We don't store webDriver as session maintains it alive
        let webDriver = WebDriver(url: winAppDriver.url)
        session = webDriver.newSession(app: "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App")
    }

    var header: Element?
    var calculatorResult: Element?

    // Executed before each test
    public override func setUp() {
        header = Self.session.findElement(byAccessibilityId: "Header") ??
                 Self.session.findElement(byAccessibilityId: "ContentPresenter")

        calculatorResult = Self.session.findElement(byAccessibilityId: "CalculatorResults")!
    }

    // Called once after all tests in this class have run
    public override class func tearDown() {
        // Force the destruction of the session
        session = nil
        winAppDriver = nil
    }

    // Test methods

    private var calculatorResultText: String {
        calculatorResult!.text.replacingOccurrences(of: "Display is", with: String()).trimmingCharacters(in: .whitespacesAndNewlines);
    }

   public func testAddition() {
        Self.session.findElement(byName: "One")?.click();
        Self.session.findElement(byName: "Plus")?.click();
        Self.session.findElement(byName: "Seven")?.click();
        Self.session.findElement(byName: "Equals")?.click();
        XCTAssertEqual("8", calculatorResultText);
    }
}