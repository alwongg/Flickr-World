//
//  DroppablePin.swift
//  Flickr World
//
//  Created by Alex Wong on 11/25/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import MapKit

//create custom pin
class DroppablePin: NSObject, MKAnnotation{
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
