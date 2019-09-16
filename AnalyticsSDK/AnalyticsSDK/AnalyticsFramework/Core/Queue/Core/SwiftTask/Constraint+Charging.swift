import Foundation
import UIKit

internal final class BatteryChargingConstraint: TaskConstraint {

    // To avoid cyclic ref
    private weak var actual: SwiftOperation?

    func batteryStateDidChange(notification: NSNotification) {
        if let task = actual, UIDevice.current.batteryState == .charging {
            // Avoid task to run multiple times
            actual = nil
            task.run()
        }
    }

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        guard operation.info.requireCharging else { return }

        /// Start listening
        NotificationCenter.default.addObserver(
                self,
                selector: Selector(("batteryStateDidChange:")),
                name: UIDevice.batteryStateDidChangeNotification,
                object: nil
        )
    }

    func willRun(operation: SwiftOperation) throws {}

    func run(operation: SwiftOperation) -> Bool {
        guard operation.info.requireCharging else {
            return true
        }

        guard UIDevice.current.batteryState != .charging else {
            return true
        }

        /// Keep actual task
        actual = operation
        return false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
