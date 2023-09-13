import class Foundation.Thread
import struct Foundation.TimeInterval
import struct Dispatch.DispatchTime

/// Calls a closure repeatedly with exponential backoff until it reports success or a timeout elapses.
/// - Returns: The result from the last invocation of the closure.
internal func poll<Value>(
        timeout: TimeInterval,
        initialPeriod: TimeInterval = 0.001,
        work: () throws -> PollResult<Value>) rethrows -> PollResult<Value> {
    let startTime = DispatchTime.now()
    var result = try work()
    if result.success { return result }

    var period = initialPeriod
    while true {
        // Check if we ran out of time and return the last result
        let elapsedTime = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        let remainingTime = timeout - elapsedTime
        if remainingTime < 0 { return result }

        // Sleep for the next period and retry
        let sleepTime = min(period, remainingTime)
        Thread.sleep(forTimeInterval: sleepTime)

        result = try work()
        if result.success { return result }

        period *= 2 // Exponential backoff
    }
}

/// Calls a closure repeatedly with exponential backoff until it reports success or a timeout elapses.
/// - Returns: Whether the closure reported success within the expected time.
internal func poll(
        timeout: TimeInterval,
        initialPeriod: TimeInterval = 0.001,
        work: () throws -> Bool) rethrows -> Bool {
    try poll(timeout: timeout, initialPeriod: initialPeriod) {
        PollResult(value: Void(), success: try work())
    }.success
}

internal struct PollResult<Value> {
    let value: Value
    let success: Bool

    static func success(_ value: Value) -> PollResult<Value> {
        PollResult(value: value, success: true)
    }
    
    static func failure(_ value: Value) -> PollResult<Value> {
        PollResult(value: value, success: false)
    }
}