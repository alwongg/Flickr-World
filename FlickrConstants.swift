//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/17/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import UIKit

// MARK: FlickrConstants

struct Constants{
    
    // MARK: Build Flickr URL
    
    struct Flickr {
        
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
    }
    
    // MARK: Search Bounding Box
    // 4 values that define the search area
    
    struct BoundingBox {
        static let BoundingBoxHalfWidth = 1.0
        static let BoundingBoxHalfHeight = 1.0
        static let BoundingBoxLatitudeRange = (-90.0, 90.0) // -90 = South, 90 = North
        static let BoundingBoxLongitudeRange = (-180.0, 180.0) // -180 = West, 180 = East
        
    }
    
    // MARK: Flickr Parameter Keys
    
    struct FlickrParameterKeys{
        static let Method = "method"
        static let ApiKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    // MARK: Flickr Parameter Values
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let ApiKey = "83956b3844d41723156c2a1bbccf3fe8"
        static let ResponseFormat = "json"
        static let DisableJSONCallBack = "1"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let NumberOfImagePerPage = "21"
    }
    
    // MARK: Flickr Response Keys
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    // MARK: Return random page number
    
    static func pageNumber() -> String{
        let num = Int(arc4random_uniform(1000))
        return "\(num)"
    }
}
