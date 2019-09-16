import Foundation

internal final class SwiftOperationQueue: OperationQueue {

    private let params: SwiftManagerParams

    private let creator: TaskCreator
    private let queue: Queue

    private let persister: TaskPersister
    private let serializer: TaskInfoSerializer
    private let listener: TaskListener?

    private let trigger: Operation = TriggerOperation()

    init(_ params: SwiftManagerParams, _ queue: Queue, _ isSuspended: Bool) {
        self.params = params
        self.queue = queue
        self.creator = params.TaskCreator

        self.persister = params.persister
        self.serializer = params.serializer
        self.listener = params.listener

        super.init()

        self.isSuspended = isSuspended

        self.name = queue.name
        self.maxConcurrentOperationCount = queue.maxConcurrent

        if params.initInBackground {
            params.dispatchQueue.async { [weak self] in
                self?.loadSerializedTasks(name: queue.name)
            }
        } else {
            self.loadSerializedTasks(name: queue.name)
        }
    }

    private func loadSerializedTasks(name: String) {
        persister.restore(queueName: name).compactMap { string -> SwiftOperation? in
            do {
                let info = try serializer.deserialize(json: string)
                let task = creator.create(type: info.type, params: info.params)

                return SwiftOperation(task: task, info: info, listener: listener, dispatchQueue: params.dispatchQueue)
            } catch let _ {
                return nil
            }
        }.sorted { operation, operation2 in
            operation.info.createTime < operation2.info.createTime
        }.forEach { operation in
            self.addOperationInternal(operation, wait: false)
        }
        super.addOperation(trigger)
    }

    override func addOperation(_ ope: Operation) {
        self.addOperationInternal(ope, wait: true)
    }

    private func addOperationInternal(_ ope: Operation, wait: Bool) {
        guard !ope.isFinished else { return }

        if wait {
            ope.addDependency(trigger)
        }

        guard let task = ope as? SwiftOperation else {
            // Not a task Task I don't care
            super.addOperation(ope)
            return
        }

        do {
            try task.willScheduleTask(queue: self)
        } catch let error {
            task.abort(error: error)
            return
        }

        // Serialize this operation
        if task.info.isPersisted {
            persistTask(task: task)
        }
        task.completionBlock = { [weak self] in
            self?.completed(task)
        }
        super.addOperation(task)
    }

    func persistTask(task: SwiftOperation) {
        do {
            let data = try serializer.serialize(info: task.info)
            persister.put(queueName: queue.name, taskId: task.info.uuid, data: data)
        } catch _ {
        }
    }

    func cancelOperations(tag: String) {
        for case let operation as SwiftOperation in operations where operation.info.tags.contains(tag) {
            operation.cancel()
        }
    }

    func cancelOperations(uuid: String) {
        for case let operation as SwiftOperation in operations where operation.info.uuid == uuid {
            operation.cancel()
        }
    }

    private func completed(_ task: SwiftOperation) {
        // Remove this operation from serialization
        if task.info.isPersisted {
            persister.remove(queueName: queue.name, taskId: task.info.uuid)
        }

        task.remove()
    }

    func createHandler(type: String, params: [String: Any]?) -> Task {
        return creator.create(type: type, params: params)
    }

}

internal class TriggerOperation: Operation {}
