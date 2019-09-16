import Foundation
import Reachability

/// Kind of connectivity required for the task to run
public enum NetworkType: Int, Codable {
    /// Task will run regardless the connectivity of the platform
    case any = 0
    /// Requires at least cellular such as 2G, 3G, 4G, LTE or Wifi
    case cellular = 1
    /// Device has to be connected to Wifi or Lan
    case wifi = 2
}

internal final class NetworkConstraint: TaskConstraint {

    var reachability: Reachability?

    func willSchedule(queue: SwiftOperationQueue, operation: SwiftOperation) throws {
        self.reachability = operation.info.requireNetwork.rawValue > NetworkType.any.rawValue ? Reachability() : nil
    }

    func willRun(operation: SwiftOperation) throws {
        guard let reachability = reachability else { return }
        guard hasCorrectNetwork(reachability: reachability, required: operation.info.requireNetwork) else {
            try reachability.startNotifier()
            return
        }
    }

    func run(operation: SwiftOperation) -> Bool {
        guard let reachability = reachability else {
            return true
        }

        if hasCorrectNetwork(reachability: reachability, required: operation.info.requireNetwork) {
            return true
        }

        reachability.whenReachable = { reachability in
            reachability.stopNotifier()
            reachability.whenReachable = nil
            operation.run()
        }

        return false
    }

    private func hasCorrectNetwork(reachability: Reachability, required: NetworkType) -> Bool {
        switch required {
        case .any:
            return true
        case .cellular:
            return reachability.connection != .none
        case .wifi:
            return reachability.connection == .wifi
        }
    }

}
