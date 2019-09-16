import Foundation

internal protocol TaskConstraint {

    /**
        - Operation will be added to the queue
        Raise exception if the task cannot run
    */
    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws

    /**
        - Operation will run
        Raise exception if the task cannot run anymore
    */
    func willRun(operation: SwiftOperation) throws

    /**
        - Operation will run
        Return false if the task cannot run immediately
    */
    func run(operation: SwiftOperation) -> Bool

}

/// Behaviour for retrying the task
public enum RetryConstraint {
    /// Retry after a certain time. If set to 0 it will retry immediately
    case retry(delay: TimeInterval)
    /// Will not retry, onRemoved will be called immediately
    case cancel
    /// Exponential back-off
    case exponential(initial: TimeInterval)
    /// Exponential back-off with max delay
    case exponentialWithLimit(initial: TimeInterval, maxDelay: TimeInterval)
}

internal class DefaultNoConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {}

    func willRun(operation: SwiftOperation) throws {}

    func run(operation: SwiftOperation) -> Bool { return true }

}
