//
//  Capital.swift
//  projectSixteen
//
//  Created by Atheer on 2019-06-08.
//  Copyright © 2019 Atheer. All rights reserved.
//

import MapKit
import UIKit

// MKAnnotation is what defines a place on the map
class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    // constructer
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
    
    
    

}
