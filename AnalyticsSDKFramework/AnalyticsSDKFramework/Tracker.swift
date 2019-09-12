//
//  Tracker.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
import UIKit

/// Tracker is a simple wrapper to send the same event to multiple analytics services.
/// Use the default tracker on Tracker to get started.
public struct Tracker {
    
    //MARK: - Shared instances
    fileprivate (set) public static var sharedInsatance = Tracker()
    
    //MARK: - Private variables
    
    /// All the analytics services supported by the Tracker. See `func configure(with services: [TrackerService])` to configure the services.
    private let services: [TrackerService]
    
    /// This creates a UUID that postfix any event that needs to be tracked onces
    fileprivate (set) var onceEventsUUID: String = UUID().uuidString
    
    //MARK: - Constructor
    private init(withServices services: [TrackerService] = [TrackerDebugService()]) {
        self.services = services
    }
    
    // MARK: - Configuration
    
    /// Configures the Tracker with the given analytics services. This method calls  "func start()" internally.
    ///
    /// - Parameter services: An array of one or more class that implement the `TrackerService` protocol.
    public static func configure(with services: [TrackerService]) {
        Tracker.sharedInsatance = Tracker(withServices: services)
        
        Tracker.start()
    }
    
    // MARK: - Session state
    
    /// Call this method to notify all services that the tracking should be started. The best place to call this method is in `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)`.
    public static func start() {
       Tracker.sharedInsatance.services.forEach { (service) in
            service.start()
        }
    }
    
    /// Call this method to notify all service that tracking should end. The best place to call this method is in `func applicationWillTerminate(_ application: UIApplication)`.
    public static func end() {
        Tracker.sharedInsatance.onceEventsUUID = UUID().uuidString
        Tracker.sharedInsatance.services.forEach { (service) in
            service.stop()
        }
    }
}

//MARK: - Tracking of events

extension Tracker {
    
    fileprivate func onceToken(forEvent event: String) -> String {
        return event + "_" + onceEventsUUID
    }
    
    /// Call this method to send an event to selected services that support the `TrackerEventAnalytics` protocol.
    ///
    /// - Parameter event: An TrackerEvent to send.
    public func track<T>(withServices services: [String])
        -> (_ event: TrackerEvent<T>)
        -> (_ payload: T?)
        -> Void {
            return { (_ event: TrackerEvent<T>)
                -> (_ payload: T?)
                -> Void in
                return { (_ payload: T?) -> Void in
                    _ = self.services
                        .filter { service -> Bool in services.contains(service.serviceName) }
                        .compactMap { $0 as? TrackerEventAnalytics }
                        .map { eventTrackerServices -> Void in eventTrackerServices.trackEvent(event.name, withProperties: payload.dictionary, priority: event.priority) }
                }
            }
    }
    
    /// Call this method to send an event to selected services that support the `TrackerEventAnalytics` protocol.
    /// But only once in the session of the Tracker, if the app is restarted from scratch, it will track again.
    /// The properties will be ignored when checking if the event was already sent.
    /// This can be used to only track the first visit of the user to a certain view.
    ///
    /// - Parameter event: An TrackerEvent to send.
    public func trackOnce<T>(withServices services: [String])
        -> (_ event: TrackerEvent<T>)
        -> (_ payload: T?)
        -> Void {
            return { (_ event: TrackerEvent<T>)
                -> (_ payload: T?)
                -> Void in
                return { (_ payload: T?) -> Void in
                    DispatchQueue.once(token: self.onceToken(forEvent: event.name)) {
                        self.track(withServices: services)(event)(payload)
                    }
                }
            }
    }
}

// MARK: - Tracking of timed events

public extension Tracker {
    
    /// Tells selected services that implement `TrackerTimedEventAnalytics` to start timing the event.
    ///
    /// - Parameter event: An TrackerEvent to send. The properties might be ignored and should be added to the stop method instead.
    func startTiming<T>(withServices services: [String])
        -> (_ event: TrackerEvent<T>)
        -> Void {
            return { (_ event: TrackerEvent<T>)
                -> Void in
                _ = self.services
                    .filter { service -> Bool in services.contains(service.serviceName) }
                    .compactMap { $0 as? TrackerTimedEventAnalytics }
                    .map { eventTrackerServices -> Void in eventTrackerServices.startTimingEvent(event.name) }
            }
    }
    
    /// Tells selected services that implement `TrackerTimedEventAnalytics` to stop timing the event.
    ///
    /// - Parameter event: An TrackerEvent to send.
    func stopTiming<T>(withServices services: [String])
        -> (_ event: TrackerEvent<T>)
        -> (_ payload: T?)
        -> Void {
            return { (_ event: TrackerEvent<T>)
                -> (_ payload: T?)
                -> Void in
                return { (_ payload: T?) -> Void in
                    _ = self.services
                        .filter { service -> Bool in services.contains(service.serviceName) }
                        .compactMap { $0 as? TrackerTimedEventAnalytics }
                        .map { eventTrackerServices -> Void in eventTrackerServices.stopTimingEvent(event.name, withProperties: payload?.dictionary, priority: event.priority) }
                }
            }
    }
    
}

// MARK: - Super properties for events

extension Tracker {
    /// Registers "super" properties with the selected analytics services that implement `TrackerEventSuperPropertiesAnalytics`.
    /// Super propeeties are properties that are added to every event that is tracked. Check the documentation for the analytics services you use to see if this is supported.
    ///
    /// - Parameter properties: The properties to register.
    public func registerEventSuperProperties<T: Codable>(withServices services: [String])
        -> (_ payload: T)
        -> Void {
            return { (_ payload: T)
                -> Void in
                _ = self.services
                    .filter { service -> Bool in services.contains(service.serviceName) }
                    .compactMap { $0 as? TrackerEventSuperPropertiesAnalytics }
                    .map { superPropertyTrackerService -> Void in
                        payload.dictionary.map({ superPropertyTrackerService.registerEventSuperProperties($0) })}
            }
    }
    
    /// Removes all the super properties for the selected analytics services that implement `TrackerEventSuperPropertiesAnalytics`.
    public func clearEventSuperProperties(withServices services: [String]) -> () -> Void {
        return { () -> Void in
            _ = self.services
                .filter { service -> Bool in services.contains(service.serviceName) }
                .compactMap { $0 as? TrackerEventSuperPropertiesAnalytics }
                .map { $0.clearEventSuperProperties() }
        }
    }
    
}

// MARK: - Remote notifications

extension Tracker {
    
    /// Registers the push notifications push token with selected services that implement the `TrackerPushNotificationAnalytics` protocol.
    ///
    /// - Parameter deviceToken: The raw push token.
    public func registerForPushNotifications(withServices services: [String])
        -> (_ pushToken: Data)
        -> () {
            return { (_ pushToken: Data)
                -> Void in
                _ = self.services
                    .filter { service -> Bool in services.contains(service.serviceName) }
                    .compactMap { $0 as? TrackerPushNotificationAnalytics }
                    .map { $0.registerForPushNotifications(pushToken) }
            }
    }
    
    /// Call this method when a notification was opnened. This needs to be done from:
    /// `func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])` and `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)` when using the iOS SDK before iOS 10.
    /// And `func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void)` on iOS 10 when using the notification center API.
    ///
    /// - Parameter payload: The payload of the notification.
    public func trackPushNotificationOpen(withServices services: [String])
        -> (_ payload: [AnyHashable: Any])
        -> Void {
            return { (_ payload: [AnyHashable: Any]) -> Void in
                _ = self.services
                    .filter { service -> Bool in services.contains(service.serviceName) }
                    .compactMap { $0 as? TrackerPushNotificationAnalytics }
                    .map { $0.trackPushNotificationOpen(payload) }
            }
    }
}

// MARK: - User profiling

extension Tracker {
    
    /// Call this method to identify the user with addtional information. Selected analytics services that implement `TrackerUserProfileAnalytics` will receieve a basic profile.
    /// But can contain more information in the `customProperties` property. Any nil items in the User profile should be removed, so be sure to always fill the user profile.
    ///
    /// - Parameter profile: The profile to identify the user with.
    public func identify(withServices services: [String])
        -> (_ profile: TrackerUserProfile)
        -> Void {
            return { (_ profile: TrackerUserProfile) -> Void in
                _ = self.services
                    .filter { service -> Bool in services.contains(service.serviceName) }
                    .compactMap { $0 as? TrackerUserProfileAnalytics }
                    .map { $0.identify(using: profile) }
            }
    }
    
}

