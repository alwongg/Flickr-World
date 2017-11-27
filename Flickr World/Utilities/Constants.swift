//
//  Constants.swift
//  Flickr World
//
//  Created by Alex Wong on 11/26/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation

// MARK: - Flickr API

let API_KEY = "04785954f464f228568d49fb889c2231"

func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int ) -> String {
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.longitude)&lon=\(annotation.coordinate.latitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    print(url)
    return url
}
