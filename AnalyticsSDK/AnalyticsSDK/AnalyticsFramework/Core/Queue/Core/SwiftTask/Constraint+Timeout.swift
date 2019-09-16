import Foundation

internal final class TimeoutConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        // Nothing to do
    }

    func willRun(operation: SwiftOperation) throws {
        // Nothing to do
    }

    func run(operation: SwiftOperation) -> Bool {
        guard let timeout = operation.info.timeout else {
            return true
        }

        operation.dispatchQueue.runAfter(timeout) {
            if operation.isExecuting && !operation.isFinished {
                operation.cancel(with: SwiftTaskError.timeout)
            }
        }

        return true
    }

}
