import Foundation
import FoundationNetworking

struct WebDriver {
    let rootURL : URL

    init(url: URL) {
        self.rootURL = url
    }

    private func send(path: String, method: String, jsonBody: Data? = nil) throws -> Data {
        var result: Data?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)

        var request = URLRequest(url: rootURL.appendingPathComponent(path))
        request.httpMethod = method
        if let jsonBody = jsonBody {
            request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "content-type")
            request.httpBody = jsonBody
        }

        print("Request: \(request.url!) \(method) " + String(decoding: request.httpBody ?? Data(), as: UTF8.self))

        let task = URLSession.shared.dataTask(with: request) { (data, response, requestError) in
            if let requestError = requestError {
                error = requestError
            }
            else if let data = data {
                print("Response data: " + String(decoding: data, as: UTF8.self))
                if let response: HTTPURLResponse = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        result = data
                    }
                    else {
                        error = try? JSONDecoder().decode(WebDriverError.self, from: data)
                    }
                }
            }

            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        if let error = error { throw error }
        return result!
    }

    func sendGet<ResponseValue>(path: String, args: [String: String] = [:]) throws -> WebDriverResponse<ResponseValue> where ResponseValue : Decodable {
        let result = try send(path: path, method: "GET")
        return try JSONDecoder().decode(WebDriverResponse<ResponseValue>.self, from: result)
    }
    
    func sendPost(path: String) throws {
        _ = try send(path: path, method: "POST")
    }

    func sendPost<Request>(path: String, request: Request) throws -> Request.Response where Request : WebDriverRequest {
        let result = try send(path: path, method: "POST", jsonBody: try JSONEncoder().encode(request))
        return try JSONDecoder().decode(Request.Response.self, from: result)
    }

    func sendDelete(path: String) throws {
        _ = try send(path: path, method: "DELETE")
    }
}