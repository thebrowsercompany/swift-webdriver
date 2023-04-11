import Foundation
import FoundationNetworking

extension URLRequest {

    // Simple Send extension to handle the complexity of sending to a web service
    // // TODO: consider making this function async/awaitable
    func send() throws -> (status: Int, Data?, Error?) {
        var result: (status: Int, data: Data?, error: Error?)?

        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: self) { (data, response, requestError) in
            let response: HTTPURLResponse = response as! HTTPURLResponse
            
            result = (status: response.statusCode, data: data, error: requestError)
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return result!
    }
}


