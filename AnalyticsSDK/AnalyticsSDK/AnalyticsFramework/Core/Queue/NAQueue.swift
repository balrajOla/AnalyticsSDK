//
//  Queue.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

internal struct NAQueueEventData {
    let event: String
    let data: [String: Any]?
    
    func toJSON() -> [String: Any] {
        guard let dataValue = self.data else {
            return ["event": self.event]
        }
        
        return ["event": self.event, "data": dataValue]
    }
    
    static func toObj(json: [String: Any]) -> NAQueueEventData? {
        guard let eventName = json["event"] as? String else {
            return nil
        }
        
        guard let dataValue = json["data"] as? [String: Any] else {
            return NAQueueEventData(event: eventName, data: nil)
        }
        
        return NAQueueEventData(event: eventName, data: dataValue)
    }
}

internal struct NAQueue {
    //MARK: - Private Variables
    fileprivate let taskManager: SwiftTaskManager
    fileprivate let maxConcurrentLimit = 4
    fileprivate let retryPolicy: RetryConstraint = RetryConstraint.exponential(initial: 2)
    fileprivate let taskBuilder = TaskBuilder(type: "NAAnalyticsTask")
                                  .parallel(queueName: "NAAnalytics")
                                  .internet(atLeast: .cellular)
                                  .retry(limit: .limited(5))
                                  .persist(required: true)
                                  .service(quality: .background)
    
    init(withHandler handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)],
        _ response: @escaping (ResultT<Single, Error>) -> ()) -> ())) {
        self.taskManager = SwiftTaskManagerBuilder(creator: NAQueueTaskCreator(withHandler: handler, retryPolicy: retryPolicy), maxConcurrencyLimit: maxConcurrentLimit).build()
    }
    
    func push(forData data: [(event: String, payload: [String: Any]?)]) {
        let mappedData = data.map({ value -> NAQueueEventData in NAQueueEventData(event: value.event, data: value.payload) })
        
        taskBuilder.singleInstance(forId: UUID().uuidString)
                   .with(params: ["eventData": mappedData.map {$0.toJSON()}])
                   .schedule(manager: self.taskManager)
    }
}
