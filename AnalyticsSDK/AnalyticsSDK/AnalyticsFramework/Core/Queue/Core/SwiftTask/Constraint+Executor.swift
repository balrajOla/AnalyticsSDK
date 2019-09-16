import Foundation

internal final class ExecutorConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        // Nothing to do
    }

    func willRun(operation: SwiftOperation) throws {
        // Nothing to do
    }

    func run(operation: SwiftOperation) -> Bool {
        switch operation.info.executor {
        case .background:
            return false
        case .foreground:
            return true
        case.any:
            return true
        }
    }

}
