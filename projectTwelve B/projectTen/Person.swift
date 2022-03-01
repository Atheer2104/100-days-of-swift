//
//  Person.swift
//  projectTen
//
//  Created by Atheer on 2019-05-27.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

// codeable we want to read and write this class
class Person: NSObject, Codable  {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
}
