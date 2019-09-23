//
//  NAQueueTaskCreator.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 16/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

struct NAQueueTaskCreator: TaskCreator {
    //MARK: - Private Variable
    fileprivate let callbackHandler: ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (ResultT<Single, Error>) -> ()) -> ())
    fileprivate let retryPolicy: RetryConstraint
    
    init(withHandler handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (ResultT<Single, Error>) -> ()) -> ()), retryPolicy: RetryConstraint) {
        self.callbackHandler = handler
        self.retryPolicy = retryPolicy
    }
    
    /// method called when a task has be to instantiate
    /// Type as specified in TaskBuilder.init(type) and params as TaskBuilder.with(params)
    func create(type: String, params: [String: Any]?) -> Task {
        guard let paramValue = params?["eventData"] as? [[String: Any]] else {
            return DummyTask()
        }
        
        let mappedDataValue = paramValue.compactMap { NAQueueEventData.toObj(json: $0) }
        
        let mappedData = mappedDataValue.map({ value -> (event: String, payload: [String: Any]?) in
            return (event: value.event, payload: value.data)
        })
        
        // Return our actual job.
        return NAAnalyticsTask(withHandler: callbackHandler, retryPolicy: retryPolicy, eventData: mappedData)
    }
}
