//
//  NAAnalyticsTask.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 16/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

/// This is a dummy task if something goes wrong
struct DummyTask: Task {
    func onRun(callback: TaskResult) {
        callback.done(.success)
    }
    
    func onRetry(error: Error) -> RetryConstraint {
        return RetryConstraint.cancel
    }
    
    func onRemove(result: TaskCompletion) {
        // DO NOTHING
    }
}

class NAAnalyticsTask: Task {
    //MARK: - Private Variable
    fileprivate let callbackHandler: ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ())
    fileprivate let retryPolicy: RetryConstraint
    fileprivate let eventData: [(event: String, payload: [String: Any]?)]
    
    init(withHandler handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ()), retryPolicy: RetryConstraint, eventData: [(event: String, payload: [String: Any]?)]) {
        self.callbackHandler = handler
        self.retryPolicy = retryPolicy
        self.eventData = eventData
    }
    
    func onRun(callback: TaskResult) {
        self.callbackHandler(eventData) { response in
            switch response {
            case .success(_ ):
                callback.done(.success)
            case .failure(let err):
                callback.done(.fail(err))
            }
        }
    }
    
    func onRetry(error: Error) -> RetryConstraint {
        return retryPolicy
    }
    
    func onRemove(result: TaskCompletion) {
        // Do nothing for now
    }
}
