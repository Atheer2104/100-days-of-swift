//
//  ViewController.swift
//  projectEighteen
//
//  Created by Atheer on 2019-06-10.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*
        print("I'm inside the viewDidLoad() method.")
        // printing multiple values in one line
        print(1, 2, 3, 4, 5, separator: "-")
        // no line break
        print("Some Message", terminator: "")
        */
        
        // assert is used to setup conidtions in your app for example
        // when a file is not there then we crash the app becasue that should happen
        // so then we can try to figure out the problem and assert will not be activated
        // publishing app on app store
        /*
        assert(1 == 1, "Math failure")
        assert(1 == 2, "Math failure")
        */
        
        // breakpoint tap line number and when code reach there it will pause the app
        // you can continue your code with fn + f6 that will go throug each line
        // it can continue to next breakpoint with ctrl + cmd + y
        // in breakpoints you can also add condition by right clicking
        // on them and pressing edit breakpoint then give condition 
        for i in 1...100 {
            print("Got number \(i).")
        }
        
    }


}

