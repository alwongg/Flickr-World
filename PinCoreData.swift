//
//  PinCoreData.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/19/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import CoreData

class Pin: NSManagedObject {
    convenience init(context: NSManagedObjectContext, latitude: Double, longitude: Double) {
        self.init(context: context)
        self.latitude = latitude
        self.longitude = longitude
    }
}
