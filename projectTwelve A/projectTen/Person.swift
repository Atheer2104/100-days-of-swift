//
//  Person.swift
//  projectTen
//
//  Created by Atheer on 2019-05-27.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

// nscoding protocol to save and load object
// you need also to inherit from nsobject if you want to use nscoding
class Person: NSObject, NSCoding{
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    // decoder when reading from disk
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
    }
    
    // write to disk
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(image, forKey: "image")
    }
    
}
