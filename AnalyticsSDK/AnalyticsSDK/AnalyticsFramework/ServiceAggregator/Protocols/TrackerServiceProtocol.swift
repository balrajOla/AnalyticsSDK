//
//  TrackerServiceProtocol.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

/**
 This protocol should be implemented by every service that will be used with an instance of `Tracker`.
 To support specific features for analytics tracking, you can implement the following protocols next to `TrackerService`:
 - `TrackerEventAnalytics` to track events.
 - `TrackerTimedEventAnalytics` to track timed events.
 - `TrackerPushNotificationAnalytics` to track push notification and retrieve the push notification token.
 - `TrackerUserProfileAnalytics` to support identifying the user with some information.
 - `TrackerEventSuperPropertiesAnalytics` to support event super properties, properties that should be added to every (timed)event tracked.
 
 - important: `versionString` has to represent the version of the SDK used for the service or a self assigned version if an SDK is not used.
 */
public protocol TrackerService {
    
    /// The name of the service, this can be used to identifiy the service in `TrackerEvent`.
    var serviceName: String { get }
    
    /// The version of the service SDK used.
    var versionString: String { get }
    
    /// Called when the Tracker has been started using `func startTracking()`. Some services can use this to start a session.
    func start()
    
    /// Called when the Tracker has been stopped using `func stopTracking()`. Some services can use this to end a session.
    func stop()
}

/**
 This is basically to bypass implementing Lifecycle methods in case the Analytic SDK donot want it.
 */
public extension TrackerService {
    
    func start() {
        // Empty implementation to make the implementation optional.
    }
    
    func stop() {
        // Empty implementation to make the implementation optional.
    }
}
