//
//  EventPriority.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public enum EventPriority {
    case high
    case medium
    case low
    
    func toNAAnalyticsEventPriority() -> NAAnalyticsEventPriority {
        switch self {
        case .high:
            return .high
        case .medium:
            return .medium
        case .low:
            return .low
        }
    }
}
