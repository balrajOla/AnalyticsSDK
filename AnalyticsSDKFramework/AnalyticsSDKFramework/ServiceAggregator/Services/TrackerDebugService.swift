//
//  TrackerDebugService.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public struct TrackerDebugLogEntry {
    var date: Date
    var text: String
    
    func description() -> String {
        return "\(self.date): \(text)"
    }
}

open class TrackerDebugService: NSObject, TrackerService, TrackerEventAnalytics, TrackerTimedEventAnalytics, TrackerPushNotificationAnalytics, TrackerUserProfileAnalytics, TrackerEventSuperPropertiesAnalytics {
    
    public var serviceName = "DEBUGTRACKER"
    
    public var versionString = "1.0"
    
    //MARK: - Logging
    
    private func logEntry(_ text: String) {
        let entry = TrackerDebugLogEntry(date: Date(), text: text)
        print(entry.description())
    }
    
    public func start() {
        self.logEntry("Starting \(self.serviceName) tracker")
    }
    
    public func pause() {
        self.logEntry("Pausing \(self.serviceName) tracker")
    }
    
    public func resume() {
        self.logEntry("Resuming \(self.serviceName) tracker")
    }
    
    public func stop() {
        self.logEntry("Stopping \(self.serviceName) tracker")
    }
    
    //MARK: - Events
    
    public func trackEvent(_ event: String, withProperties properties: [String : Any]?) {
        if let properties = properties {
            self.logEntry("\(self.serviceName): Track event \"\(event)\" with properties \"\(properties.debugDescription)\"")
        } else {
            self.logEntry("\(self.serviceName): Track event \"\(event)\" without properties")
        }
        
    }
    
    //MARK: - Timed events
    
    public func startTimingEvent(_ event: String) {
        self.logEntry("\(self.serviceName): Start timing \"\(event)\"")
    }
    
    public func stopTimingEvent(_ event: String, withProperties properties: [String : Any]?) {
        if let properties = properties {
            self.logEntry("\(self.serviceName): Stop timing \"\(event)\" with properties\"\(properties.debugDescription)\"")
        } else {
            self.logEntry("\(self.serviceName): Stop timing \"\(event)\" without properties")
        }
    }
    
    //MARK: - Push Notifications
    
    public func registerForPushNotifications(_ pushToken: Data) {
        let deviceTokenString = pushToken.description.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
        self.logEntry("\(self.serviceName): Register for push notifications with token: \"\(deviceTokenString)\"")
    }
    
    //MARK: - Push Notifications Events
    
    public func trackPushNotificationOpen(_ payload: [AnyHashable : Any]) {
        self.logEntry("\(self.serviceName): Track open push notification with payload \"\(payload.debugDescription)\"")
    }
    
    //MARK: - User Profiles
    
    public func identify(using profile: TrackerUserProfile) {
        if let profileName = profile.fullName {
            self.logEntry("\(self.serviceName): Identify user profile (\(profile)) with name \"\(profileName)\"")
        } else {
            self.logEntry("\(self.serviceName): Identify user profile (\(profile))")
        }
        
    }
    
    //MARK: - Event Super Properties
    
    public func registerEventSuperProperties(_ properties: [String: Any]) {
        self.logEntry("\(self.serviceName): Register event super properties \"\(properties.debugDescription)\"")
    }
    
    public func clearEventSuperProperties() {
        self.logEntry("\(self.serviceName): Reset event super properties")
    }
    
}
