import Foundation
import Dispatch

/// Global manager to perform operations on all your queues/
/// You will have to keep this instance. We highly recommend you to store this instance in a Singleton
/// Creating and instance of this class will automatically un-serialize your tasks and schedule them
public final class SwiftTaskManager {

    internal let params: SwiftManagerParams
    
    internal init(params: SwiftManagerParams, isSuspended: Bool) {
        self.params = params
        self.isSuspended = isSuspended
        
        for queueName in params.persister.restore() {
            _ = createQueue(queueName: queueName)
        }
    }

    /// Allow tasks in queue to be executed.
    public var isSuspended: Bool {
        didSet {
            for element in manage.values {
                element.isSuspended = isSuspended
            }
        }
    }

    private var manage = [String: SwiftOperationQueue]()

    internal func getQueue(queueName: String) -> SwiftOperationQueue {
        return manage[queueName] ?? createQueue(queueName: queueName)
    }

    private func createQueue(queueName: String) -> SwiftOperationQueue {
        let operationQueue = SwiftOperationQueue(params, params.queueCreator.create(queueName: queueName, maxParallel: params.maxConcurrencyLimit), isSuspended)
        manage[queueName] = operationQueue
        return operationQueue
    }

    /// Schedule a task to the queue
    public func enqueue(info: TaskInfo) {
        let queue = getQueue(queueName: info.queueName)
        let task = queue.createHandler(type: info.type, params: info.params)

        let operation = SwiftOperation(task: task,
                info: info,
                listener: params.listener,
                dispatchQueue: params.dispatchQueue
        )

        queue.addOperation(operation)
    }

    /// All operations in all queues will be removed
    public func cancelAllOperations() {
        for element in manage.values {
            element.cancelAllOperations()
        }
    }

    /// All operations with this tag in all queues will be removed
    public func cancelOperations(tag: String) {
        assertNotEmptyString(tag)
        for element in manage.values {
            element.cancelOperations(tag: tag)
        }
    }

    /// All operations with this uuid in all queues will be removed
    public func cancelOperations(uuid: String) {
        assertNotEmptyString(uuid)
        for element in manage.values {
            element.cancelOperations(uuid: uuid)
        }
    }

    /// Blocks the current thread until all of the receiver’s queued and executing operations finish executing.
    public func waitUntilAllOperationsAreFinished() {
        for element in manage.values {
            element.waitUntilAllOperationsAreFinished()
        }
    }

    /// number of queue
    public func queueCount() -> Int {
        return manage.values.count
    }

    /// number of tasks for all queues
    public func taskCount() -> Int {
        var count = 0
        for element in manage.values {
            count += element.operationCount
        }
        return count
    }
}

internal extension SwiftTaskManager {

    func getAllAllowBackgroundOperation() -> [SwiftOperation] {
        return manage.values
                .flatMap { $0.operations }
                .compactMap { $0 as? SwiftOperation }
                .filter { $0.info.executor.rawValue > 0 }
    }

    func getOperation(forUUID: String) -> SwiftOperation? {
        for queue: SwiftOperationQueue in manage.values {
            for operation in queue.operations where operation.name == forUUID {
                return operation as? SwiftOperation
            }
        }
        return nil
    }
}

internal struct SwiftManagerParams {

    let TaskCreator: TaskCreator

    let queueCreator: QueueCreator

    var persister: TaskPersister

    var serializer: TaskInfoSerializer

    var listener: TaskListener?

    var dispatchQueue: DispatchQueue

    var initInBackground: Bool
    
    var maxConcurrencyLimit: Int

    init(TaskCreator: TaskCreator,
         queueCreator: QueueCreator,
         persister: TaskPersister = UserDefaultsPersister(),
         serializer: TaskInfoSerializer = DecodableSerializer(),
         listener: TaskListener? = nil,
         initInBackground: Bool = false,
         maxConcurrencyLimit: Int = 1,
         dispatchQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    ) {
        self.TaskCreator = TaskCreator
        self.queueCreator = queueCreator
        self.persister = persister
        self.serializer = serializer
        self.listener = listener
        self.initInBackground = initInBackground
        self.maxConcurrencyLimit = maxConcurrencyLimit
        self.dispatchQueue = dispatchQueue
    }

}

/// Entry point to create a `SwiftTaskManager`
public final class SwiftTaskManagerBuilder {

    private var params: SwiftManagerParams
    private var isSuspended: Bool = false

    /// Creator to convert `TaskInfo.type` to `Task` instance
    public init(creator: TaskCreator, maxConcurrencyLimit: Int = 1, queueCreator: QueueCreator = BasicQueueCreator()) {
        params = SwiftManagerParams(TaskCreator: creator, queueCreator: queueCreator, maxConcurrencyLimit: maxConcurrencyLimit)
    }

    /// Custom way of saving `TaskInfo`. Will use `UserDefaultsPersister` by default
    public func set(persister: TaskPersister) -> Self {
        params.persister = persister
        return self
    }

    /// Custom way of serializing `TaskInfo`. Will use `DecodableSerializer` by default
    public func set(serializer: TaskInfoSerializer) -> Self {
        params.serializer = serializer
        return self
    }

    /// Start tasks directly when they are scheduled or not. `false` by default
    public func set(isSuspended: Bool) -> Self {
        self.isSuspended = isSuspended
        return self
    }

    /// Deserialize tasks synchronously after creating the `SwiftTaskManager` instance. `true` by default
    public func set(initInBackground: Bool) -> Self {
        params.initInBackground = initInBackground
        return self
    }

    /// Listen for task
    public func set(listener: TaskListener) -> Self {
        params.listener = listener
        return self
    }

    public func set(dispatchQueue: DispatchQueue) -> Self {
        params.dispatchQueue = dispatchQueue
        return self
    }

    /// Get an instance of `SwiftTaskManager`
    public func build() -> SwiftTaskManager {
        return SwiftTaskManager(params: params, isSuspended: isSuspended)
    }

}
