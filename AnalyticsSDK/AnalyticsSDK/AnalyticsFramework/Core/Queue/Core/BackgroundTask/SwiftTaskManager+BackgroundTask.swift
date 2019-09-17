#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

@available(iOS 13.0, *)
/// Extension of SwiftTaskManager to support BackgroundTask API from iOS 13.
public extension SwiftTaskManager {

    /// Register task that can potentially run in Background (Using BackgroundTask API)
    /// Registration of all launch handlers must be complete before the end of applicationDidFinishLaunching(_:)
    /// https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler/3180427-register
    func registerForBackgroundTask(forTaskWithUUID: String) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: forTaskWithUUID, using: nil) { [weak self] task in
            if let operation = self?.getOperation(forUUID: task.identifier) {
                task.expirationHandler = {
                    operation.done(.fail(SwiftTaskError.timeout))
                }
                operation.handler.onRun(callback: TaskResultImp(actual: operation, task: task))
            }
        }
    }

    /// Call this method when application is entering background to schedule tasks as background task
    func applicationDidEnterBackground() {
        for operation in getAllAllowBackgroundOperation() {
            operation.scheduleBackgroundTask()
        }
    }

    /// Cancel all possible background Task
    func cancelAllBackgroundTask() {
        for operation in getAllAllowBackgroundOperation() {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: operation.info.uuid)
        }
    }
}

@available(iOS 13.0, *)
internal extension SwiftOperation {

    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: info.uuid)

        request.requiresNetworkConnectivity = info.requireNetwork.rawValue > NetworkType.any.rawValue
        request.requiresExternalPower = info.requireCharging
        request.earliestBeginDate = nextRunSchedule

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
        }
    }
}

@available(iOS 13.0, *)
private class TaskResultImp: TaskResult {

    private let task: BGTask
    private let actual: TaskResult

    init(actual: TaskResult, task: BGTask) {
        self.actual = actual
        self.task = task
    }

    public func done(_ result: TaskCompletion) {
        actual.done(result)

        switch result {
        case .success:
            task.setTaskCompleted(success: true)
        case .fail:
            task.setTaskCompleted(success: false)
        }
    }
}
