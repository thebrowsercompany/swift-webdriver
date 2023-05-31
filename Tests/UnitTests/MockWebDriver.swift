import XCTest
@testable import WebDriver

/// A mock WebDriver implementation which can be configured
/// to expect certain requests and fail if they don't match.
class MockWebDriver: WebDriver {
    struct Expectation {
        let path: String
        let method: HTTPMethod
        let handler: (Data?) throws -> Data?
    }

    var expectations: [Expectation] = []

    deinit {
        // We should have met all of our expectations
        XCTAssertEqual(expectations.count, 0)
    }

    /// Queues an expected request and specifies its response handler
    func expect<RequestBody: Codable, Response: Codable>(path: String, method: HTTPMethod, handler: @escaping (RequestBody) throws -> Response) {
        expectations.append(Expectation(path: path, method: method, handler: {
            let requestBody: RequestBody
            if let requestBodyData = $0 {
                requestBody = try JSONDecoder().decode(RequestBody.self, from: requestBodyData)
            }
            else if RequestBody.self == CodableNone.self {
                requestBody = CodableNone() as Any as! RequestBody
            }
            else {
                XCTFail("Expected a request body")
                fatalError("Unreachable")
            }
             
            let responseValue = try handler(requestBody)
            return ResponseValue.self == CodableNone.self ? nil : try! JSONEncoder().encode(responseValue)
        }))
    }

    func expect<Request: WebDriverRequest>(path: String, method: HTTPMethod, type: Request.Type, handler: @escaping (Request.Body) throws -> Request.ResponseValue) {
        expect(path: path, method: method) {
            (requestBody: Request.Body) -> Request.ResponseValue in try handler(requestBody)
        }
    }

    /// Queues an expected request and specifies its response handler
    func expect<ResponseValue: Codable>(path: String, method: HTTPMethod, handler: @escaping () throws -> ResponseValue) {
        expect(path: path, method: method) { (requestBody: CodableNone) -> ResponseValue in try handler() }
    }

    /// Queues an expected request
    func expect(path: String, method: HTTPMethod) {
        expect(path: path, method: method) { (requestBody: CodableNone) -> CodableNone in WebDriverResponse<CodableNone>() }
    }

    @discardableResult
    func send<Request: WebDriverRequest>(_ request: Request) throws -> Request.Response {
        XCTAssertNotEqual(expectations.count, 0)

        let expectation = expectations.remove(at: 0)
        XCTAssertEqual(request.pathComponents.joined(separator: "/"), expectation.path)
        XCTAssertEqual(request.method, expectation.method)

        let requestBody: Data? = Request.Body.self == CodableNone.self
            ? nil : try JSONEncoder().encode(request.body)

        let responseData = try expectation.handler(requestBody)

        return try JSONDecoder().decode(Request.Response.self, from: responseData!)
    }
}