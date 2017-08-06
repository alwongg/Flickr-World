//
//  PhotoCoreData.swift
//  Virtual Tourist2.0
//
//  Created by Alex Wong on 8/4/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import CoreData
import UIKit

class Photo: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, url: String) {
        self.init(context: context)
        self.url = url
    }
    func connectArrayOfPhotosToPin(pin: Pin)  {
        myPin = pin
    }
    func updateData(data: Data) {
        self.image = data as NSData
    }
}
