//
//  TrackerEvent.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

public struct TrackerEvent<T: Codable> {
    let name: String
    let priority: EventPriority
    
    public init(name: String, priority: EventPriority) {
        self.name = name
        self.priority = priority
    }
}
