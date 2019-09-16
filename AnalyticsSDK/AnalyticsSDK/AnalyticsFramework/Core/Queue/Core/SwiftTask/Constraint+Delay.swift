import Foundation

internal final class DelayConstraint: TaskConstraint {

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        // Nothing to do
    }

    func willRun(operation: SwiftOperation) throws {
        // Nothing to do
    }

    func run(operation: SwiftOperation) -> Bool {
        guard let delay = operation.info.delay else {
            // No delay run immediately
            return true
        }

        let epoch = Date().timeIntervalSince(operation.info.createTime)
        guard epoch < delay else {
            // Epoch already greater than delay
            return true
        }

        let time: Double = abs(epoch - delay)

        operation.nextRunSchedule = Date().addingTimeInterval(time)
        operation.dispatchQueue.runAfter(time, callback: { [weak operation] in
            // If the operation in already deInit, it may have been canceled
            // It's safe to ignore the nil check
            // This is mostly to prevent task retention when cancelling operation with delay
            operation?.run()
        })

        return false
    }
}
