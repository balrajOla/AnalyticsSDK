import Foundation

/// Protocol to create instance of your task
public protocol TaskCreator {

    /// method called when a task has be to instantiate
    /// Type as specified in TaskBuilder.init(type) and params as TaskBuilder.with(params)
    func create(type: String, params: [String: Any]?) -> Task

}

public protocol QueueCreator {

    func create(queueName: String, maxParallel: Int) -> Queue

}

/// Method to implement to have a custom persister
public protocol TaskPersister {

    /// Return an array of QueueName persisted
    func restore() -> [String]

    /// Restore all task in a single queue
    func restore(queueName: String) -> [String]

    /// Add a single task to a single queue with custom params
    func put(queueName: String, taskId: String, data: String)

    /// Remove a single task for a single queue
    func remove(queueName: String, taskId: String)

}

/// Class to serialize and deserialize `TaskInfo`
public protocol TaskInfoSerializer {

    /// Convert `TaskInfo` into a representable string
    func serialize(info: TaskInfo) throws -> String

    /// Convert back a string to a `TaskInfo`
    func deserialize(json: String) throws -> TaskInfo

}

/// Callback to give result in synchronous or asynchronous task
public protocol TaskResult {

    /// Method callback to notify the completion of your 
    func done(_ result: TaskCompletion)

}

/// Enum to define possible Task completion values
public enum TaskCompletion {

    /// Task completed successfully
    case success

    /// Task completed with error
    case fail(Swift.Error)

}

/// Protocol to implement to run a task
public protocol Task {

    /// Perform your operation
    /// Will be called in background thread
    func onRun(callback: TaskResult)

    /// Fail has failed with the 
    /// Will only gets called if the task can be retried
    /// Not applicable for 'ConstraintError'
    /// Not application if the retry(value) is less than 2 which is the case by default
    /// Will be called in background thread
    func onRetry(error: Swift.Error) -> RetryConstraint

    /// Task is removed from the queue and will never run again
    /// May be called in background or main thread
    func onRemove(result: TaskCompletion)

}

public protocol Queue {

    var name: String { get }

    var maxConcurrent: Int { get }

}

public enum BasicQueue {
    case synchronous
    case concurrent
    case custom(String, Int)
}

public class BasicQueueCreator: QueueCreator {

    public init() {}

    public func create(queueName: String, maxParallel: Int) -> Queue {
        switch queueName {
        case "GLOBAL": return BasicQueue.synchronous
        case "MULTIPLE": return BasicQueue.concurrent
        default: return BasicQueue.custom(queueName, maxParallel)
        }
    }

}

extension BasicQueue: Queue {

    public var name: String {
        switch self {
        case .synchronous : return "GLOBAL"
        case .concurrent : return "MULTIPLE"
        case .custom(let variable, _) : return variable
        }
    }

    public var maxConcurrent: Int {
        switch self {
        case .synchronous : return 1
        case .concurrent : return 2
        case .custom(_, let parallel) : return parallel
        }
    }

}

/// Listen from task status
public protocol TaskListener {

    /// Task will start executing
    func onBeforeRun(task: TaskInfo)

    /// Task completed execution
    func onAfterRun(task: TaskInfo, result: TaskCompletion)

    /// Task is removed from the queue and will not run anymore
    func onTerminated(task: TaskInfo, result: TaskCompletion)

}

/// Enum to specify a limit
public enum Limit {

    /// No limit
    case unlimited

    /// Limited to a specific number
    case limited(Double)

}

/// Generic class for any constraint violation
public enum SwiftTaskError: Swift.Error {

    /// Task has been canceled
    case canceled

    /// Deadline has been reached
    case deadline

    /// Exception thrown when you try to schedule a task with a same ID as one currently scheduled
    case duplicate

    /// Task canceled inside onError. Parameter contains the origin error
    case onRetryCancel(Error)

    /// Task took too long to run
    case timeout

}

/// Enum to specify background and foreground restriction
public enum Executor: Int {

    /// Task will only run only when the app is in foreground
    case foreground = 0

    /// Task will only run only when the app is in background
    case background = 1

    /// Task can run in both background and foreground
    case any = 2

}
