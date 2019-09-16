//
//  AnalyticsTrackerConstants.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

struct ButtonClick: Codable {
    let name = "CLick Here Button"
}

struct TrackerEventConstants {
    public static let trackApplicationLaunch = Tracker.sharedInsatance.track(withServices: [NAAnalyticsServiceConstants.serviceName])(TrackerEvent<Single>(name: "ApplicationFinishLaunching", priority: .high))
    
    public static let trackLaunchScreenViewDidLoad = Tracker.sharedInsatance.track(withServices: [NAAnalyticsServiceConstants.serviceName])(TrackerEvent<Single>(name: "LaunchScreenViewDidLoad", priority: .medium))
    
    public static let trackLaunchScreenViewWillAppear = Tracker.sharedInsatance.track(withServices: [NAAnalyticsServiceConstants.serviceName])(TrackerEvent<Single>(name: "LaunchScreenViewWillAppear", priority: .medium))
    
    public static let trackLaunchScreenButtonClicked = Tracker.sharedInsatance.track(withServices: [NAAnalyticsServiceConstants.serviceName])(TrackerEvent<ButtonClick>(name: "LaunchScreenButtonClicked", priority: .medium))
}
