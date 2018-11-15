//
//  LandingViewController.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 11/15/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, ClientDelegate {

    func userDidUpdate() {
        let boolValue = LDClient.sharedInstance()?.boolVariation("hello", fallback: false)
        let dicValues = LDClient.sharedInstance()?.dictionaryVariation("dic-01", fallback: [:])
    }
    
    func featureFlagDidUpdate(_ key: String!) {
        print(key)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Override point for customization after application launch.
        let user = LDUserBuilder()
        user.key = UIDevice.current.identifierForVendor?.uuidString
        
        let config = LDConfig(mobileKey: "mob-6834fa3f-983f-4526-a5ad-c374004f4fae")
        LDClient.sharedInstance()?.start(config, with: user)
        LDClient.sharedInstance()?.delegate = self
        LDClient.sharedInstance()?.flush()
        
        let dicValues = LDClient.sharedInstance()?.dictionaryVariation("dic-01", fallback: [:])
        let arrayValues = LDClient.sharedInstance()?.arrayVariation("dic-01", fallback: [])
        let stringValue = LDClient.sharedInstance()?.stringVariation("dic-01", fallback: "")
        // Do any additional setup after loading the view.
    }

}
