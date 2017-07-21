//
//  PhotoCoreData.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/19/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import CoreData

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
