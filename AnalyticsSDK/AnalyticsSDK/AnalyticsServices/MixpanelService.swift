//
//  MixpanelService.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
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
        return "1.0"
    }
    
    /// Creates the analytice service with the given Mixpanel token.
    ///
    /// - Parameter apiKey: The token for mixpanel.
    init(token: String) {
        Mixpanel.initialize(token: "")
    }
    
}

/// MARK: - TrackerEventAnalytics
extension MixpanelService: TrackerEventAnalytics {
    
    func trackEvent(_ event: String, withProperties properties: [String : Any]?, priority: EventPriority) {
        let properties = properties as? Properties
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }
    
}

/// MARK: - TrackerTimedEventAnalytics
extension MixpanelService: TrackerTimedEventAnalytics {
    
    func startTimingEvent(_ event: String) {
        Mixpanel.mainInstance().time(event: event)
    }
    
    func stopTimingEvent(_ event: String, withProperties properties: [String : Any]?, priority: EventPriority) {
        self.trackEvent(event, withProperties: properties, priority: priority)
    }
    
}

/// MARK: - TrackerPushNotificationAnalytics
extension MixpanelService: TrackerPushNotificationAnalytics {
    
    func trackPushNotificationOpen(_ payload: [AnyHashable: Any]) {
    }
    
    func registerForPushNotifications(_ deviceToken: Data) {
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
            Mixpanel.mainInstance().identify(distinctId: identifier)
            var properties = [String: MixpanelType]()
            
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
                properties[key] = property as? MixpanelType
            }
            
            Mixpanel.mainInstance().people.set(properties: properties)
        }
    }
    
}

/// MARK: - TrackerEventSuperPropertiesAnalytics
extension MixpanelService: TrackerEventSuperPropertiesAnalytics {
    
    func registerEventSuperProperties(_ properties: [String : Any]) {
        let properties = properties as? Properties
        properties.map { Mixpanel.mainInstance().registerSuperProperties($0) }
    }
    
    func clearEventSuperProperties() {
        Mixpanel.mainInstance().clearSuperProperties()
    }
    
}
