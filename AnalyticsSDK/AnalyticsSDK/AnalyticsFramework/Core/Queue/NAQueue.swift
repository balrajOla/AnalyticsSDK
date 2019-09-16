//
//  Queue.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

internal struct NAQueue {
    //MARK: - Private Variables
    fileprivate let taskManager: SwiftTaskManager
    fileprivate let maxConcurrentLimit = 4
    fileprivate let retryPolicy: RetryConstraint = RetryConstraint.exponential(initial: 2)
    fileprivate let taskBuilder = TaskBuilder(type: "NAAnalyticsTask")
                                  .parallel(queueName: "NAAnalytics")
                                  .internet(atLeast: .cellular)
                                  .retry(limit: .limited(5))
                                  .service(quality: .background)
    
    init(withHandler handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)],
        _ response: @escaping (Result<Single, Error>) -> ()) -> ())) {
        self.taskManager = SwiftTaskManagerBuilder(creator: NAQueueTaskCreator(withHandler: handler, retryPolicy: retryPolicy), maxConcurrencyLimit: maxConcurrentLimit).build()
    }
    
    func push(forData data: [(event: String, payload: [String: Any]?)]) {
        taskBuilder.with(params: ["eventData": data])
                   .schedule(manager: self.taskManager)
    }
}
