//
//  NoonAcademyAnalyticsCore.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public class NoonAcademyAnalytics {
    
    //MARK: - Public shared instance
    public static let sharedInstance = NoonAcademyAnalytics()
    
    //MARK: - Private Variables
    fileprivate var callbackHandler: ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ())?
    fileprivate var token = UUID().uuidString
    fileprivate var startedDate: Date = Date()
    fileprivate var bufferStream: Buffer?
    
    //MARK: - Private Constructor
    private init() {}
    
    //MARK: - Configuration
    /// This function sets the callback handler and calls `func start()`
    public func configure(handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ()))
        -> (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)])
        -> Void {
            return {[weak self] (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)]) -> Void in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.once(token: self.token) {
                    self.callbackHandler = handler
                    
                    self.start(withConfiguration: configuration)
                }
            }
    }
    
    //MARK: - Public Function
    /// This initiates the analytics sdk
    public func start(withConfiguration configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)]) {
        guard let _ = self.callbackHandler else {
            fatalError("NoonAcademyAnalytics need to be configured before starting")
        }
        
        self.startedDate = Date()
        
        //Create a new instance of Buffer
        self.bufferStream = Buffer(with: {[weak self] event in
            guard let self = self else {
                return
            }
            
            //TODO:- Push to this data to the queue and then callback handler will be called here
            
            self.callbackHandler?(event.map({ (event: $0.event, payload: $0.payload) })) { _ in
                // TODO: Call Queue system to delete the data if success or inform queue to retry
            }
        }, configuration)
    }
    
    /// This function tracks the analytics events sent via application
    /// - Parameter event: This is the name of the event that needs to be logged
    /// - Parameter payload: This is an optional field that carries extra data for given event
    public func track(event: String, priority: EventPriority, payload: [String: Any]?) {
        // Prepare the data to be sent
        // push it in the buffer
        self.bufferStream?.push(withPriority: priority.toNAAnalyticsEventPriority())((event: event, payload: payload))
    }
    
    /// Should be called to end the analytics sdk
    public func stop() {
        self.token = UUID().uuidString
        
        //Close the running buffer
        self.bufferStream?.close()
        
        //TODO:- Complete the Queue
    }
}
