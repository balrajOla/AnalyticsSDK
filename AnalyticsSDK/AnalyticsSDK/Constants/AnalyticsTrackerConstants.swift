//
//  AnalyticsTrackerConstants.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
import AnalyticsSDKFramework

struct TrackerEventConstants {
    public static let trackLaunchScreenViewDidLoad = Tracker.sharedInsatance.track(withServices: [TrackerDebugServiceConstant.serviceName])(TrackerEvent<Single>(name: "LaunchScreenViewDidLoad", priority: .high))
}
