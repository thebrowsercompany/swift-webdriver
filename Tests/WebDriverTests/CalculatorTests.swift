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

    public func testDivision()
    {
        // Find the buttons by their accessibility ids and click them in sequence to perform 88 / 11 = 8
        Self.session.findElement(byAccessibilityId: "num8Button")?.click();
        Self.session.findElement(byAccessibilityId: "num8Button")?.click();
        Self.session.findElement(byAccessibilityId: "divideButton")?.click();
        Self.session.findElement(byAccessibilityId: "num1Button")?.click();
        Self.session.findElement(byAccessibilityId: "num1Button")?.click();
        Self.session.findElement(byAccessibilityId: "equalButton")?.click();
        XCTAssertEqual("8", calculatorResultText);
    }

    public func testMultiplication()
    {
        // Find the buttons by their names using XPath and click them in sequence to perform 9 x 9 = 81
        Self.session.findElement(byXPath:  "//Button[@Name='Nine']")?.click();
        Self.session.findElement(byXPath:  "//Button[@Name='Multiply by']")?.click();
        Self.session.findElement(byXPath:  "//Button[@Name='Nine']")?.click();
        Self.session.findElement(byXPath:  "//Button[@Name='Equals']")?.click();
        XCTAssertEqual("81", calculatorResultText);
    }

    public func testSubtraction()
    {
        // Find the buttons by their accessibility ids using XPath and click them in sequence to perform 9 - 1 = 8
        Self.session.findElement(byXPath:  "//Button[@AutomationId=\"num9Button\"]")?.click();
        Self.session.findElement(byXPath:  "//Button[@AutomationId=\"minusButton\"]")?.click();
        Self.session.findElement(byXPath:  "//Button[@AutomationId=\"num1Button\"]")?.click();
        Self.session.findElement(byXPath:  "//Button[@AutomationId=\"equalButton\"]")?.click();
        XCTAssertEqual("8", calculatorResultText);
    }
}