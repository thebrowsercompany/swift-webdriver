import Foundation
import FoundationNetworking

extension URLRequest {

    // Simple Send extension to handle the complexity of sending to a web service
    // // TODO: consider making this function async/awaitable
    func send() throws -> (Int, Data?, Error?) {
        var error: Error?
        var result: Data?
        var status: Int?
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: self) { (data, response, requestError) in
            if let response: HTTPURLResponse = response as? HTTPURLResponse {
                status = response.statusCode
            }
            error = requestError
            result = data
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        if let error = error { throw error }
        return (status!, result, error)
    }
}


