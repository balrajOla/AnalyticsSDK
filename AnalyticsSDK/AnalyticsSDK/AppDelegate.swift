//
//  AppDelegate.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Tracker.configure(with: [TrackerDebugService()])
        Tracker.configure(with: [NAAnalyticsService()])
        
        
        TrackerEventConstants.trackApplicationLaunch(nil)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        Tracker.end()
    }



}

