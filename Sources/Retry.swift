import Foundation

// Retry the given work using exponential backoff until we use the allocated time or work returns non-nil.
internal func retryUntil<T>(_ timeout: TimeInterval, work: () throws -> T?) rethrows -> T? {
    var timeUsed: TimeInterval = 0.0
    var nextTimeout: TimeInterval = 0.001 // Start at 1ms and double until we exhaust time.

    var result: T?
    repeat {
        result = try work()
        if let result {
            return result
        }

        if timeUsed < timeout {
            Thread.sleep(forTimeInterval: nextTimeout)
            timeUsed += nextTimeout
            nextTimeout = min(nextTimeout * 2.0, timeout - timeUsed)
        } else {
            break
        }
    } while true

    return result
}
