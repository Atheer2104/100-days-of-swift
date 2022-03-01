//
//  ViewController.swift
//  projectTwelve
//
//  Created by Atheer on 2019-05-31.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        // we can save what ever we would like to
        defaults.set(25, forKey: "Age")
        defaults.set(true, forKey: "UserFaceID")
        defaults.set(CGFloat.pi, forKey: "Pi")
        
        defaults.set("Atheer", forKey: "Name")
        defaults.set(Date(), forKey: "LastRun")
        
        let array = ["hello", "world"]
        defaults.set(array, forKey: "SavedArray")
        
        let dictionary = ["Name": "Atheer", "Country": "Iraq"]
        defaults.set(dictionary, forKey: "SavedDictonary")
        
        // if not found will be 0 and for bool default is false
        let savedInteger = defaults.integer(forKey: "Age")
        let savedBoolean = defaults.bool(forKey: "UserFaceID")
        
        // if we found our array then it's good else if not found
        // we create new empty string, we tell it what type it's
        // because it doesn't know
        let savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        
        let savedDictionary = defaults.object(forKey: "SavedDictonary") as? [String: String] ??
        [String: String]()
    
    }


}

