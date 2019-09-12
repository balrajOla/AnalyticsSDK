//
//  NoonAcademyAnalyticsCore.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public struct NoonAcademyAnalytics {

    //MARK: - Shared instances
    fileprivate (set) public static var sharedInstance = NoonAcademyAnalytics()
    
    // MARK: - Private Variables
    fileprivate var callbackHandler: ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ())?
    fileprivate var token = UUID().uuidString
    fileprivate var startedDate: Date = Date()
    
    //MARK: - Private Constructor
    private init() {}
    
    //MARK: - Configuration
    /// This function sets the callback handler and calls `func start()`
    public static func configure(handler: @escaping ((_ data: [(event: String, payload: [String: Any]?)], _ response: @escaping (Result<Single, Error>) -> ()) -> ())) {
        DispatchQueue.once(token: NoonAcademyAnalytics.sharedInstance.token) {
            NoonAcademyAnalytics.sharedInstance.callbackHandler = handler
            
            NoonAcademyAnalytics.start()
        }
    }
    
    //MARK: - Public Function
    /// This initiates the analytics sdk
    public static func start() {
        guard let _ = NoonAcademyAnalytics.sharedInstance.callbackHandler else {
            fatalError("NoonAcademyAnalytics need to be configured before starting")
        }
        
        NoonAcademyAnalytics.sharedInstance.startedDate = Date()
        
        //TODO: - Create a new instance of Buffer
    }
    
    /// This function tracks the analytics events sent via application
    /// - Parameter event: This is the name of the event that needs to be logged
    /// - Parameter payload: This is an optional field that carries extra data for given event
    public func track(event: String, priority: EventPriority, payload: [String: Any]?) {
        // Prepare the data to be sent
        
        // push it in the buffer
    }
    
    /// Should be called to end the analytics sdk
    public static func end() {
        NoonAcademyAnalytics.sharedInstance.token = UUID().uuidString
        
        //TODO: - Complete the running buffer
    }
}
