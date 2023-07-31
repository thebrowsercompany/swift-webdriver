import Foundation

// Retry the given work using exponential backoff until we use the allocated time or work returns non-nil.
internal func retryUntil<T>(_ timeout: TimeInterval, work: () throws -> T?) rethrows -> T? {
    var timeUsed: TimeInterval = 0.0
    var nextTimeout: TimeInterval = 0.001 // Start at 1ms and double until we exhaust time.

    repeat {
        if let result = try work() { return result }

        if timeUsed < timeout {
            Thread.sleep(forTimeInterval: nextTimeout)
            timeUsed += nextTimeout
            nextTimeout = min(nextTimeout * 2.0, timeout - timeUsed)
        } else {
            return nil
        }
    } while true
}

// Retry the given work using exponential backoff until we use allocated time or work returns true.
internal func retryUntil(_ timeout: TimeInterval, work: () throws -> Bool) rethrows {
    var timeUsed: TimeInterval = 0.0
    var nextTimeout: TimeInterval = 0.001 // Start at 1ms and double until we exhaust time.

    repeat {
        if try work() { return }

        if timeUsed < timeout {
            Thread.sleep(forTimeInterval: nextTimeout)
            timeUsed += nextTimeout
            nextTimeout = min(nextTimeout * 2.0, timeout - timeUsed)
        } else {
            return
        }
    } while true
}
