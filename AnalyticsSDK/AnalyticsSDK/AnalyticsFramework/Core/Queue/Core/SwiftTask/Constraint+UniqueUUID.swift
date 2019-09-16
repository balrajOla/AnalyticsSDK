import Foundation

internal final class UniqueUUIDConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        for ope in queue.operations where ope.name == operation.info.uuid {
            if shouldAbort(ope: ope, operation: operation) {
                if operation.info.override {
                    ope.cancel()
                    break
                } else {
                    throw SwiftTaskError.duplicate
                }
            }
        }
    }

    private func shouldAbort(ope: Operation, operation: SwiftOperation) -> Bool {
        return (ope.isExecuting && operation.info.includeExecutingTask) || !ope.isExecuting
    }

    func willRun(operation: SwiftOperation) throws {
        // Nothing to check
    }

    func run(operation: SwiftOperation) -> Bool {
        // Nothing to check
        return true
    }
}
