import Foundation

/// Info related to a single task. Those information may be serialized and persisted
/// In order to re-create the task in the future.
public struct TaskInfo {

    /// Type of task to create actual `Task` instance
    let type: String

    /// Queue name
    var queueName: String

    /// Unique identifier for a task
    var uuid: String

    /// Override task when scheduling a task with same uuid
    var override: Bool

    /// Including task that are executing when scheduling with same uuid
    var includeExecutingTask: Bool

    /// Set of identifiers
    var tags: Set<String>

    /// Delay for the first execution of the task
    var delay: TimeInterval?

    /// Cancel the task after a certain date
    var deadline: Date?

    /// Require a certain connectivity type
    var requireNetwork: NetworkType

    /// Indicates if the task should be persisted inside a database
    var isPersisted: Bool

    /// Custom params set by the user
    var params: [String: Any]

    /// Date of the task's creation
    var createTime: Date

    /// Time between each repetition of the task
    var interval: TimeInterval

    /// Executor to run task in foreground or background
    var executor: Executor

    /// Number of run maximum
    var maxRun: Limit

    /// Maximum number of authorised retried
    var retries: Limit

    /// Current number of run
    var runCount: Double

    var requireCharging: Bool

    /// Current number of repetition. Transient value
    var currentRepetition: Int

    /// This value is used to influence the order in which operations are dequeued and executed
    var priority: Operation.QueuePriority

    /// The relative amount of importance for granting system resources to the operation.
    var qualityOfService: QualityOfService

    var timeout: TimeInterval?

    func buildConstraints() -> [TaskConstraint] {
        var constraints = [TaskConstraint]()

        constraints.append(UniqueUUIDConstraint())
        constraints.append(ExecutorConstraint())

        if requireCharging {
            constraints.append(BatteryChargingConstraint())
        }

        if deadline != nil {
            constraints.append(DeadlineConstraint())
        }

        if delay != nil {
            constraints.append(DelayConstraint())
        }

        if requireNetwork != NetworkType.any {
            constraints.append(NetworkConstraint())
        }

        if timeout != nil {
            constraints.append(TimeoutConstraint())
        }

        return constraints
    }

    init(type: String) {
        self.init(
                type: type,
                queueName: "GLOBAL",
                uuid: UUID().uuidString,
                override: false,
                includeExecutingTask: true,
                tags: Set<String>(),
                delay: nil,
                deadline: nil,
                requireNetwork: NetworkType.any,
                isPersisted: false,
                params: [:],
                createTime: Date(),
                interval: -1.0,
                maxRun: .limited(0),
                executor: .foreground,
                retries: .limited(0),
                runCount: 0,
                requireCharging: false,
                priority: .normal,
                qualityOfService: .background,
                timeout: nil
        )
    }

    internal init(type: String,
                  queueName: String,
                  uuid: String,
                  override: Bool,
                  includeExecutingTask: Bool,
                  tags: Set<String>,
                  delay: TimeInterval?,
                  deadline: Date?,
                  requireNetwork: NetworkType,
                  isPersisted: Bool,
                  params: [String: Any],
                  createTime: Date,
                  interval: TimeInterval,
                  maxRun: Limit,
                  executor: Executor,
                  retries: Limit,
                  runCount: Double,
                  requireCharging: Bool,
                  priority: Operation.QueuePriority,
                  qualityOfService: QualityOfService,
                  timeout: TimeInterval?
    ) {

        self.type = type
        self.queueName = queueName
        self.uuid = uuid
        self.override = override
        self.includeExecutingTask = includeExecutingTask
        self.tags = tags
        self.delay = delay
        self.deadline = deadline
        self.requireNetwork = requireNetwork
        self.isPersisted = isPersisted
        self.params = params
        self.createTime = createTime
        self.interval = interval
        self.maxRun = maxRun
        self.executor = executor
        self.retries = retries
        self.runCount = runCount
        self.requireCharging = requireCharging
        self.priority = priority
        self.qualityOfService = qualityOfService
        self.timeout = timeout

        /// Transient
        self.currentRepetition = 0
    }
}
