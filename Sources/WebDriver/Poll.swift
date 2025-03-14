import class Foundation.Thread
import struct Foundation.TimeInterval
import struct Dispatch.DispatchTime

/// Calls a closure repeatedly with exponential backoff until it reports success or a timeout elapses.
/// Thrown errors bubble up immediately, returned errors allow retries.
/// - Returns: The successful value.
public func poll<Value>(
        timeout: TimeInterval,
        initialPeriod: TimeInterval = 0.001,
        work: () throws -> Result<Value, Error>) throws -> Value {
    let startTime = DispatchTime.now()
    var lastResult = try work()
    var period = initialPeriod
    while true {
        guard case .failure = lastResult else { break }

        // Check if we ran out of time and return the last result
        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        let remainingTime = timeout - elapsedTime
        if remainingTime < 0 { break }

        // Sleep for the next period and retry
        let sleepTime = min(period, remainingTime)
        Thread.sleep(forTimeInterval: sleepTime)

        lastResult = try work()
        period *= 2 // Exponential backoff
    }

    return try lastResult.get()
}

/// Calls a closure repeatedly with exponential backoff until it reports success or a timeout elapses.
/// - Returns: Whether the closure reported success within the expected time.
public func poll(
        timeout: TimeInterval,
        initialPeriod: TimeInterval = 0.001,
        work: () throws -> Bool) throws -> Bool {
    struct FalseError: Error {}
    do {
        try poll(timeout: timeout, initialPeriod: initialPeriod) {
            try work() ? .success(()) : .failure(FalseError())
        }
        return true
    } catch _ as FalseError {
        return false
    }
}
