//
//  MixpanelService.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
import AnalyticsSDKFramework
import Mixpanel

/**
 Adding a service requires to first implement the Mixpanel SDK. See these steps: https://mixpanel.com/help/reference/swift
 */

/// An example implementation of Mixpanel as an TrackerService.
/// Supports:
/// - Event analytics
/// - User profiles
/// - Timed analytics
/// - Push notifications
/// - Super properties
struct MixpanelService: TrackerService {
    
    var serviceName = "Mixpanel"
    
    var versionString: String {
        return self.mixpanelTracker?.libVersion() ?? "1.0"
    }
    
    var mixpanelTracker: Mixpanel!
    
    /// Creates the analytice service with the given Mixpanel token.
    ///
    /// - Parameter apiKey: The token for mixpanel.
    init(token: String) {
        super.init()
        self.mixpanelTracker = Mixpanel.sharedInstance(withToken: token)
    }
    
}

/// MARK: - TrackerEventAnalytics
extension MixpanelService: TrackerEventAnalytics {
    
    func trackEvent(_ event: String, withProperties properties: [String : Any]?) {
        self.mixpanelTracker.track(event, properties: properties)
    }
    
}

/// MARK: - TrackerTimedEventAnalytics
extension MixpanelService: TrackerTimedEventAnalytics {
    
    func startTimingEvent(_ event: String) {
        self.mixpanelTracker.timeEvent(event)
    }
    
    func stopTimingEvent(_ event: String, withProperties properties: [String : Any]?) {
        self.trackEvent(event, withProperties: properties)
    }
    
}

/// MARK: - TrackerPushNotificationAnalytics
extension MixpanelService: TrackerPushNotificationAnalytics {
    
    func trackPushNotificationOpen(_ payload: [AnyHashable: Any]) {
        self.mixpanelTracker.trackPushNotification(payload)
    }
    
    func registerForPushNotifications(_ deviceToken: Data) {
        self.mixpanelTracker.people.addPushDeviceToken(deviceToken)
    }
    
}

/// MARK: - TrackerUserProfileAnalytics
extension MixpanelService: TrackerUserProfileAnalytics {
    
    func identify(using profile: TrackerUserProfile) {
        var identifier = profile.identifier
        if identifier == nil {
            identifier = profile.email
        }
        if let identifier = identifier {
            self.mixpanelTracker.identify(identifier)
            var properties = [String: Any]()
            
            if let value = profile.firstname {
                properties["$first_name"] = value
            }
            
            if let value = profile.lastname {
                properties["$last_name"] = value
            }
            
            if let value = profile.fullName {
                properties["$name"] = value
            }
            
            if let value = profile.email {
                properties["$email"] = value
            }
            
            if let value = profile.registationDate {
                properties["$created"] = value
            }
            
            if let value = profile.gender {
                properties["Gender"] = value.rawValue
            }
            
            //Append the last custom properties
            for (key, property) in profile.customProperties {
                properties[key] = property
            }
            
            self.mixpanelTracker.people.set(properties)
        }
    }
    
}

/// MARK: - TrackerEventSuperPropertiesAnalytics
extension MixpanelService: TrackerEventSuperPropertiesAnalytics {
    
    func registerEventSuperProperties(_ properties: [String : Any]) {
        self.mixpanelTracker.registerSuperProperties(properties)
    }
    
    func clearEventSuperProperties() {
        self.mixpanelTracker.clearSuperProperties()
    }
    
}
