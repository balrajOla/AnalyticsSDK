import Foundation

internal final class SwiftOperation: Operation {

    let handler: Task

    var info: TaskInfo

    let constraints: [TaskConstraint]

    var lastError: Swift.Error?

    let listener: TaskListener?

    let dispatchQueue: DispatchQueue

    var nextRunSchedule: Date?

    override var name: String? { get { return info.uuid } set { } }
    override var queuePriority: QueuePriority { get { return info.priority } set { } }
    override var qualityOfService: QualityOfService { get { return info.qualityOfService } set { } }

    private var taskIsExecuting: Bool = false
    override var isExecuting: Bool {
        get { return taskIsExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            taskIsExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var taskIsFinished: Bool = false
    override var isFinished: Bool {
        get { return taskIsFinished }
        set {
            willChangeValue(forKey: "isFinished")
            taskIsFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    internal init(task: Task, info: TaskInfo, listener: TaskListener?, dispatchQueue: DispatchQueue) {
        self.handler = task
        self.info = info
        self.listener = listener
        self.dispatchQueue = dispatchQueue
        self.constraints = info.buildConstraints()

        super.init()
    }

    override func start() {
        super.start()
        isExecuting = true
        run()
    }

    override func cancel() {
        self.cancel(with: SwiftTaskError.canceled)
    }

    func cancel(with: Swift.Error) {
        lastError = with
        onTerminate()
        super.cancel()
    }

    func onTerminate() {
        if isExecuting {
            isFinished = true
        }
    }

    // cancel before schedule and serialize
    internal func abort(error: Swift.Error) {
        lastError = error
        // Need to be called manually since the task is actually not in the queue. So cannot call cancel()
        handler.onRemove(result: .fail(error))
        listener?.onTerminated(task: info, result: .fail(error))
    }

    internal func run() {
        if isCancelled && !isFinished {
            isFinished = true
        }
        if isFinished {
            return
        }

        do {
            try self.willRunTask()
        } catch let error {
            // Will never run again
            cancel(with: error)
            return
        }

        guard self.checkIfTaskCanRunNow() else {
            // Constraint fail.
            // Constraint will call run when it's ready
            return
        }

        listener?.onBeforeRun(task: info)
        handler.onRun(callback: self)
    }

    internal func remove() {
        let result = lastError.map(TaskCompletion.fail) ?? TaskCompletion.success
        handler.onRemove(result: result)
        listener?.onTerminated(task: info, result: result)
    }

}

extension SwiftOperation: TaskResult {

    func done(_ result: TaskCompletion) {
        guard !isFinished else { return }

        listener?.onAfterRun(task: info, result: result)

        switch result {
        case .success:
            completionSuccess()
        case .fail(let error):
            completionFail(error: error)
        }
    }

    private func completionFail(error: Swift.Error) {
        lastError = error

        switch info.retries {
        case .limited(let value):
            if value > 0 {
                retryTask(retry: handler.onRetry(error: error), origin: error)
            } else {
                onTerminate()
            }
        case .unlimited:
            retryTask(retry: handler.onRetry(error: error), origin: error)
        }
    }

    private func retryTask(retry: RetryConstraint, origin: Error) {

        func exponentialBackoff(initial: TimeInterval) -> TimeInterval {
            info.currentRepetition += 1
            return info.currentRepetition == 1 ? initial : initial * pow(2, Double(info.currentRepetition - 1))
        }

        switch retry {
        case .cancel:
            lastError = SwiftTaskError.onRetryCancel(origin)
            onTerminate()
        case .retry(let after):
            guard after > 0 else {
                // Retry immediately
                info.retries.decreaseValue(by: 1)
                self.run()
                return
            }

            // Retry after time in parameter
            retryInBackgroundAfter(after)
        case .exponential(let initial):
            retryInBackgroundAfter(exponentialBackoff(initial: initial))
        case .exponentialWithLimit(let initial, let maxDelay):
            retryInBackgroundAfter(min(maxDelay, exponentialBackoff(initial: initial)))
        }
    }

    private func completionSuccess() {
        lastError = nil
        info.currentRepetition = 0

        if case .limited(let limit) = info.maxRun {
            // Reached run limit
            guard info.runCount + 1 < limit else {
                onTerminate()
                return
            }
        }

        guard info.interval > 0 else {
            // Run immediately
            info.runCount += 1
            self.run()
            return
        }

        // Schedule run after interval
        nextRunSchedule = Date().addingTimeInterval(info.interval)
        dispatchQueue.runAfter(info.interval, callback: { [weak self] in
            self?.info.runCount += 1
            self?.run()
        })
    }

}

extension SwiftOperation {

    func willScheduleTask(queue: SwiftOperationQueue) throws {
        for constraint in self.constraints {
            try constraint.willSchedule(queue: queue, operation: self)
        }
    }

    func willRunTask() throws {
        for constraint in self.constraints {
            try constraint.willRun(operation: self)
        }
    }

    func checkIfTaskCanRunNow() -> Bool {
        for constraint in self.constraints where constraint.run(operation: self) == false {
            return false
        }
        return true
    }

}

extension SwiftOperation {

    fileprivate func retryInBackgroundAfter(_ delay: TimeInterval) {
        nextRunSchedule = Date().addingTimeInterval(delay)
        dispatchQueue.runAfter(delay) { [weak self] in
            self?.info.retries.decreaseValue(by: 1)
            self?.run()
        }
    }

}
