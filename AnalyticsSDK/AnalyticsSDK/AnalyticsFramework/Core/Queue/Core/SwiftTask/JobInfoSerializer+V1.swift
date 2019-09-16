import Foundation

/// Using Key value serializer to match with V1 behavior
public class V1Serializer: TaskInfoSerializer {

    internal let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return formatter
    }()

    func toJSON(_ obj: [String: Any]) throws -> String? {
        assert(JSONSerialization.isValidJSONObject(obj))
        let jsonData = try JSONSerialization.data(withJSONObject: obj)
        return String(data: jsonData, encoding: .utf8)
    }

    public func serialize(info: TaskInfo) throws -> String {
        guard let json = try toJSON(info.toDictionary(dateFormatter)) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: [],
                    debugDescription: "The given data was not valid JSON.")
            )
        }
        return json
    }

    func fromJSON(_ json: String) throws -> Any {
        guard let data = json.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to convert string to utf-8")
            )
        }

        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }

    public func deserialize(json: String) throws -> TaskInfo {
        guard let dictionary = try fromJSON(json) as? [String: Any] else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Decoded value is not a dictionary")
            )
        }

        guard let type = dictionary["type"] as? String else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to retrieve task type")
            )
        }

        var taskInfo = TaskInfo(type: type)
        try taskInfo.bind(dictionary: dictionary, dateFormatter)
        return taskInfo
    }

}

internal extension TaskInfo {

    func toDictionary(_ dateFormatter: DateFormatter) -> [String: Any] {
        var dict = [String: Any]()
        dict[TaskInfoKeys.type.stringValue]                = self.type
        dict[TaskInfoKeys.uuid.stringValue]                = self.uuid
        dict[TaskInfoKeys.override.stringValue]            = self.override
        dict[TaskInfoKeys.includeExecutingTask.stringValue] = self.includeExecutingTask
        dict[TaskInfoKeys.queueName.stringValue]           = self.queueName
        dict[TaskInfoKeys.tags.stringValue]                = Array(self.tags)
        dict[TaskInfoKeys.delay.stringValue]               = self.delay
        dict[TaskInfoKeys.deadline.stringValue]            = self.deadline.map(dateFormatter.string)
        dict[TaskInfoKeys.requireNetwork.stringValue]      = self.requireNetwork.rawValue
        dict[TaskInfoKeys.isPersisted.stringValue]         = self.isPersisted
        dict[TaskInfoKeys.params.stringValue]              = self.params
        dict[TaskInfoKeys.createTime.stringValue]          = dateFormatter.string(from: self.createTime)
        dict[TaskInfoKeys.runCount.stringValue]            = self.runCount
        dict[TaskInfoKeys.executor.stringValue]            = self.executor.rawValue
        dict[TaskInfoKeys.maxRun.stringValue]              = self.maxRun.rawValue
        dict[TaskInfoKeys.retries.stringValue]             = self.retries.rawValue
        dict[TaskInfoKeys.interval.stringValue]            = self.interval
        dict[TaskInfoKeys.requireCharging.stringValue]     = self.requireCharging
        dict[TaskInfoKeys.priority.stringValue]            = self.priority.rawValue
        dict[TaskInfoKeys.qualityOfService.stringValue]    = self.qualityOfService.rawValue
        return dict
    }

    mutating func bind(dictionary: [String: Any], _ dateFormatter: DateFormatter) throws {
        dictionary.assign(TaskInfoKeys.uuid.stringValue, &self.uuid)
        dictionary.assign(TaskInfoKeys.override.stringValue, &self.override)
        dictionary.assign(TaskInfoKeys.includeExecutingTask.stringValue, &self.includeExecutingTask)
        dictionary.assign(TaskInfoKeys.queueName.stringValue, &self.queueName)
        dictionary.assign(TaskInfoKeys.tags.stringValue, &self.tags) { (array: [String]) -> Set<String> in Set(array) }
        dictionary.assign(TaskInfoKeys.delay.stringValue, &self.delay)
        dictionary.assign(TaskInfoKeys.deadline.stringValue, &self.deadline, dateFormatter.date)
        dictionary.assign(TaskInfoKeys.requireNetwork.stringValue, &self.requireNetwork, NetworkType.init)
        dictionary.assign(TaskInfoKeys.isPersisted.stringValue, &self.isPersisted)
        dictionary.assign(TaskInfoKeys.params.stringValue, &self.params)
        dictionary.assign(TaskInfoKeys.createTime.stringValue, &self.createTime, dateFormatter.date)
        dictionary.assign(TaskInfoKeys.interval.stringValue, &self.interval)
        dictionary.assign(TaskInfoKeys.maxRun.stringValue, &self.maxRun, Limit.fromRawValue)
        dictionary.assign(TaskInfoKeys.executor.stringValue, &self.executor, Executor.fromRawValue)
        dictionary.assign(TaskInfoKeys.retries.stringValue, &self.retries, Limit.fromRawValue)
        dictionary.assign(TaskInfoKeys.runCount.stringValue, &self.runCount)
        dictionary.assign(TaskInfoKeys.requireCharging.stringValue, &self.requireCharging)
        dictionary.assign(TaskInfoKeys.priority.stringValue, &self.priority, Operation.QueuePriority.init)
        dictionary.assign(TaskInfoKeys.qualityOfService.stringValue, &self.qualityOfService, QualityOfService.init)
    }
}

internal extension Dictionary where Key == String {

    func assign<A>(_ key: String, _ variable: inout A) {
        if let value = self[key] as? A {
            variable = value
        }
    }

    func assign<A, B>(_ key: String, _ variable: inout B, _ transform: (A) -> B?) {
        if let value = self[key] as? A, let transformed = transform(value) {
            variable = transformed
        }
    }

}

internal extension Limit {

    static func fromRawValue(value: Double) -> Limit {
        return value < 0 ? Limit.unlimited : Limit.limited(value)
    }

    var rawValue: Double {
        switch self {
        case .unlimited:
            return -1
        case .limited(let val):
            return val
        }
    }
}
