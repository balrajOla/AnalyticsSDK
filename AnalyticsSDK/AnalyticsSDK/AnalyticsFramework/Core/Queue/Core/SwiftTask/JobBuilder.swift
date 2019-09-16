import Foundation

/// Builder to create your task with behaviour
public final class TaskBuilder {

    private var info: TaskInfo

    /// Type of your task that you will receive in TaskCreator.create(type)
    public init(type: String) {
        assertNotEmptyString(type)
        self.info = TaskInfo(type: type)
    }

    /// Allow only 1 task at the time with this ID scheduled or running if includeExecutingTask is true
    /// Same task scheduled with same id will result in onRemove(SwiftTaskError.duplicate) if override = false
    /// If override = true the previous task will be canceled and the new task will be scheduled
    public func singleInstance(forId: String, override: Bool = false, includeExecutingTask: Bool = true) -> Self {
        assertNotEmptyString(forId)
        info.uuid = forId
        info.override = override
        info.includeExecutingTask = includeExecutingTask
        return self
    }

    /// Task in different groups can run in parallel
    public func parallel(queueName: String) -> Self {
        assertNotEmptyString(queueName)
        info.queueName = queueName
        return self
    }

    /// Delay the execution of the task.
    /// Base on the task creation, when the task is supposed to run,
    /// If the delay is already pass (longer task before) it will run immediately
    /// Otherwise it will wait for the remaining time
    public func delay(time: TimeInterval) -> Self {
        assert(time >= 0)
        info.delay = time
        return self
    }

    /// If the task hasn't run after the date, It will be removed
    /// will call onRemove(SwiftTaskError.deadline)
    public func deadline(date: Date) -> Self {
        info.deadline = date
        return self
    }

    /// Repeat task a certain number of time and with a interval between each run
    /// Limit of period to reproduce
    /// interval between each run. Does not affect the first iteration. Please add delay if so
    /// executor will make the task being scheduling to run in background with BackgroundTask API
    public func periodic(limit: Limit = .unlimited, interval: TimeInterval = 0, executor: Executor = .foreground) -> Self {
        assert(limit.validate)
        assert(interval >= 0)
        info.maxRun = limit
        info.interval = interval
        info.executor = executor
        return self
    }

    /// Connectivity constraint.
    public func internet(atLeast: NetworkType) -> Self {
        info.requireNetwork = atLeast
        return self
    }

    /// Task should be persisted. 
    public func persist(required: Bool) -> Self {
        info.isPersisted = required
        return self
    }

    /// Limit number of retry. Overall for the lifecycle of the SwiftTaskManager.
    /// For a periodic task, the retry count will not be reset at each period. 
    public func retry(limit: Limit) -> Self {
        assert(limit.validate)
        info.retries = limit
        return self
    }

    /// Custom tag to mark the task
    public func addTag(tag: String) -> Self {
        assertNotEmptyString(tag)
        info.tags.insert(tag)
        return self
    }

    /// Custom parameters will be forwarded to create method
    public func with(params: [String: Any]) -> Self {
        info.params = params
        return self
    }

    /// Set priority of the task. May affect execution order
    public func priority(priority: Operation.QueuePriority) -> Self {
        info.priority = priority
        return self
    }

    /// Set quality of service to define importance of the task system wise
    public func service(quality: QualityOfService) -> Self {
        info.qualityOfService = quality
        return self
    }

    /// Set to `true` if the task can only run when the device is charging
    public func requireCharging(value: Bool) -> Self {
        info.requireCharging = value
        return self
    }

    /// Maximum time in second that the task is allowed to run
    public func timeout(value: TimeInterval) -> Self {
        info.timeout = value
        return self
    }

    /// Get the TaskInfo built
    public func build() -> TaskInfo {
        return info
    }

    /// Add task to the TaskQueue
    public func schedule(manager: SwiftTaskManager) {
        if info.isPersisted {
            // Check if we will be able to serialize args
            assert(JSONSerialization.isValidJSONObject(info.params))
        }

        manager.enqueue(info: info)
    }
}
