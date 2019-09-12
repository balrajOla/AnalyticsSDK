//
//  NAAnalyticsService.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 12/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public struct NAAnalyticsServiceConstants {
    public static let serviceName = "NoonAcademyAnalyticsService"
    public static let versionString = "1.0"
}

/// An example implementation of NAAnalytics as an TrackerService.
/// Supports:
/// - Event analytics
struct NAAnalyticsService: TrackerService {
    
    //MARK: - Internal variables
    var serviceName: String = NAAnalyticsServiceConstants.serviceName
    var versionString: String = NAAnalyticsServiceConstants.versionString
    
    //MARK: - Private Variables
    private let analyticsService = NoonAcademyAnalytics.sharedInstance
    private let configuration = [NAAnalyticsEventPriority.high: (interval: 1, count: 1),
                         NAAnalyticsEventPriority.medium: (interval: 2, count: 5),
                         NAAnalyticsEventPriority.low: (interval: 8, count: 9)]
    
    //MARK: - Constructor
    init() {
        self.analyticsService.configure(handler: { (events, callback) in
            print("\n \n ------Noon Academy Analytics events are been looged------")
            print("\n ------START------")
            _ = events.map { event -> Void in
                if let properties = event.payload {
                    print("\n Date: \(Date()), Track event \"\(event.event)\" with properties \"\(properties.debugDescription)\"")
                } else {
                    print("\n Date: \(Date()), Track event \"\(event.event)\" without properties")
                }
            }
            print("\n------END------")
            
            callback(Result<Single, Error>.success(Single.value))
        })(configuration)
    }
    
    //MARK: - Implemented lifecycle functions
    /// Called when the Tracker has been started using `func startTracking()`. Some services can use this to start a session.
    func start() {
        self.analyticsService.start(withConfiguration: configuration)
    }
    
    /// Called when the Tracker has been stopped using `func stopTracking()`. Some services can use this to end a session.
    func stop() {
        self.analyticsService.stop()
    }
}

/// MARK: - TrackerEventAnalytics
extension NAAnalyticsService: TrackerEventAnalytics {
    
    func trackEvent(_ event: String, withProperties properties: [String : Any]?, priority: EventPriority) {
        self.analyticsService.track(event: event, priority: priority, payload: properties)
    }
    
}
