//
//  NAAnalyticsService.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 12/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
import AnalyticsSDKFramework

public struct NAAnalyticsServiceConstants {
    public static let serviceName = "NoonAcademyAnalyticsService"
    public static let versionString = "1.0"
}

/// An example implementation of NAAnalytics as an TrackerService.
/// Supports:
/// - Event analytics
struct NAAnalyticsService: TrackerService {
    
    var serviceName: String = NAAnalyticsServiceConstants.serviceName
    var versionString: String = NAAnalyticsServiceConstants.versionString
    
    let analyticsService = NoonAcademyAnalytics.sharedInstance
    
    let configuration = [NAAnalyticsEventPriority.high: (interval: 1, count: 1),
                         NAAnalyticsEventPriority.medium: (interval: 2, count: 3),
                         NAAnalyticsEventPriority.low: (interval: 4, count: 5)]
    
    init() {
        NoonAcademyAnalytics.configure(handler: { (events, callback) in
            print("\n \n ------Noon Academy Analytics events are been looged------")
            print("\n ------START------")
            _ = events.map { event -> Void in
                if let properties = event.payload {
                    print("\n Track event \"\(event.event)\" with properties \"\(properties.debugDescription)\"")
                } else {
                    print("\n Track event \"\(event.event)\" without properties")
                }
            }
            print("\n------END------")
            
            callback(Result<Single, Error>.success(Single.value))
        })(configuration)
    }
    
    /// Called when the Tracker has been started using `func startTracking()`. Some services can use this to start a session.
    func start() {
        NoonAcademyAnalytics.start(withConfiguration: configuration)
    }
    
    /// Called when the Tracker has been stopped using `func stopTracking()`. Some services can use this to end a session.
    func stop() {
        NoonAcademyAnalytics.stop()
    }
}

/// MARK: - TrackerEventAnalytics
extension NAAnalyticsService: TrackerEventAnalytics {
    
    func trackEvent(_ event: String, withProperties properties: [String : Any]?, priority: EventPriority) {
        self.analyticsService.track(event: event, priority: priority, payload: properties)
    }
    
}
