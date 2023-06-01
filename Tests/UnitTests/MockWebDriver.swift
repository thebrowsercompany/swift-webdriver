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
    func expect<Response : Encodable>(path: String, method: HTTPMethod, handler: @escaping () -> Response) {
        expectations.append(Expectation(path: path, method: method, handler: {
            let response = handler()
            return Response.self == CodableNone.self ? nil : try! JSONEncoder().encode(response)
        }))
    }

    /// Queues an expected request
    func expect(path: String, method: HTTPMethod) {
        expect(path: path, method: method) { WebDriverResponse<CodableNone>() }
    }

    @discardableResult
    func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        XCTAssertNotEqual(expectations.count, 0)

        let expectation = expectations.remove(at: 0)
        XCTAssertEqual(request.pathComponents.joined(separator: "/"), expectation.path)
        XCTAssertEqual(request.method, expectation.method)

        let responseData = expectation.handler()

        return try JSONDecoder().decode(Request.Response.self, from: responseData!)
    }
}