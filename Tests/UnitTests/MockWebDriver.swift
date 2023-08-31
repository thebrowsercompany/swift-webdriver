@testable import WebDriver
import XCTest

/// A mock WebDriver implementation which can be configured
/// to expect certain requests and fail if they don't match.
class MockWebDriver: WebDriver {
    struct UnexpectedRequestBodyError: Error {}

    struct Expectation {
        let path: String
        let method: HTTPMethod
        let handler: (Data?) throws -> Data?
    }

    var expectations: [Expectation] = []

    deinit {
        // We should have met all of our expectations.
        XCTAssertEqual(expectations.count, 0)
    }

    /// Queues an expected request and specifies its response handler.
    /// This overload is the most generic for any incoming body type and outgoing response type.
    func expect<ReqBody: Codable, Res: Codable>(path: String, method: HTTPMethod, handler: @escaping (ReqBody) throws -> Res) {
        expectations.append(Expectation(path: path, method: method, handler: {
            let requestBody: ReqBody
            if let requestBodyData = $0 {
                requestBody = try JSONDecoder().decode(ReqBody.self, from: requestBodyData)
            } else if ReqBody.self == CodableNone.self {
                requestBody = CodableNone() as Any as! ReqBody
            } else {
                throw UnexpectedRequestBodyError()
            }

            let response = try handler(requestBody)
            return Res.self == CodableNone.self ? nil : try JSONEncoder().encode(response)
        }))
    }

    /// Queues an expected request and specifies its response handler.
    /// This overload uses a Request.Type for easier type inference.
    func expect<Req: Request>(path: String, method: HTTPMethod, type: Req.Type, handler: @escaping (Req.Body) throws -> Req.Response) {
        expect(path: path, method: method) {
            (requestBody: Req.Body) -> Req.Response in try handler(requestBody)
        }
    }

    /// Queues an expected request and specifies its response handler and outoing response type.
    /// This overload ignores the incoming request body.
    func expect<Req: Request>(path: String, method: HTTPMethod, type: Req.Type, handler: @escaping () throws -> Req.Response) {
        expect(path: path, method: method) {
            () -> Req.Response in try handler()
        }
    }

    /// Queues an expected request and specifies its response handler.
    /// This overload ignores the incoming request body.
    func expect<Res: Codable>(path: String, method: HTTPMethod, handler: @escaping () throws -> Res) {
        expect(path: path, method: method) { (_: CodableNone) -> Res in try handler() }
    }

    /// Queues an expected request
    /// This overload ignores the incoming request body and returns a default response.
    func expect(path: String, method: HTTPMethod) {
        expect(path: path, method: method) {
            (_: CodableNone) in CodableNone()
        }
    }

    @discardableResult
    func send<Req: Request>(_ request: Req) throws -> Req.Response {
        XCTAssertNotEqual(expectations.count, 0)

        let expectation = expectations.remove(at: 0)
        XCTAssertEqual(request.pathComponents.joined(separator: "/"), expectation.path)
        XCTAssertEqual(request.method, expectation.method)

        let requestBody: Data? = Req.Body.self == CodableNone.self
            ? nil : try JSONEncoder().encode(request.body)

        let responseData = try expectation.handler(requestBody)
        if Req.Response.self == CodableNone.self {
            return CodableNone() as! Req.Response
        } else {
            return try JSONDecoder().decode(Req.Response.self, from: responseData!)
        }
    }
}
