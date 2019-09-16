import Foundation

internal final class DeadlineConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        try check(operation: operation)
    }

    func willRun(operation: SwiftOperation) throws {
        try check(operation: operation)
    }

    func run(operation: SwiftOperation) -> Bool {
        guard let delay = operation.info.deadline else {
            return true
        }

        operation.dispatchQueue.runAfter(delay.timeIntervalSinceNow, callback: { [weak operation] in
            guard let ope = operation else { return }
            guard !ope.isFinished else { return }

            ope.cancel(with: SwiftTaskError.deadline)
        })
        return true
    }

    private func check(operation: SwiftOperation) throws {
        if let deadline = operation.info.deadline, deadline < Date() {
            throw SwiftTaskError.deadline
        }
    }
}
