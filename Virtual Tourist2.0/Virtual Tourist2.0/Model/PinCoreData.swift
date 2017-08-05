//
//  PinCoreData.swift
//  Virtual Tourist2.0
//
//  Created by Alex Wong on 8/4/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import CoreData
import UIKit

class Pin: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, latitude: Double, longitude: Double) {
        self.init(context: context)
        self.latitude = latitude
        self.longitude = longitude
    }
}
