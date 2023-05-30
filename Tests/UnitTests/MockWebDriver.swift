import XCTest
@testable import WebDriver

/// A mock WebDriver implementation which can be configured
/// to expect certain requests and fail if they don't match.
class MockWebDriver: WebDriver {
    struct Expectation {
        let path: String
        let method: HTTPMethod
        let handler: () -> Data?
    }

    var expectations: [Expectation] = []

    deinit {
        // We should have met all of our expectations
        XCTAssertEqual(expectations.count, 0)
    }

    /// Queues an expected request and specifies its response handler
    func expect<ResponseValue : Encodable>(path: String, method: HTTPMethod, handler: @escaping () -> ResponseValue) {
        expectations.append(Expectation(path: path, method: method, handler: {
            let responseValue = handler()
            return ResponseValue.self == CodableNone.self ? nil : try! JSONEncoder().encode(responseValue)
        }))
    }

    /// Queues an expected request
    func expect(path: String, method: HTTPMethod) {
        expect(path: path, method: method) { CodableNone() }
    }

    @discardableResult
    func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        XCTAssertNotEqual(expectations.count, 0)

        let expectation = expectations.remove(at: 0)
        XCTAssertEqual(request.pathComponents.joined(separator: "/"), expectation.path)
        XCTAssertEqual(request.method, expectation.method)

        let responseValue = expectation.handler()

        var response = Request.Response()
        if Request.ResponseValue.self == WebDriverNoResponseValue.self {
            XCTAssertNil(responseValue)
        }
        else {
            XCTAssertNotNil(responseValue)
            response.value = try JSONDecoder().decode(Request.ResponseValue.self, from: responseValue!)
        }
        return response
    }
}