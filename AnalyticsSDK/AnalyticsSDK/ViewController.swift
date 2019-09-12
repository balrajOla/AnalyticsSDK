//
//  ViewController.swift
//  AnalyticsSDK
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Track `ViewDidLoad`
        TrackerEventConstants.trackLaunchScreenViewDidLoad(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TrackerEventConstants.trackLaunchScreenViewWillAppear(nil)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        TrackerEventConstants.trackLaunchScreenButtonClicked(nil)
    }
}

