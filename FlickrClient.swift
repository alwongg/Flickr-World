//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/17/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import MapKit

// MARK: FlickrClient: NSObject

class FlickrClient: NSObject {
    
    // MARK: Properties
    
    var session = URLSession.shared
    
    // MARK: Initializer
    
    override init() {
        
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Task for GET method
    
    func getFlickrImages(_ methodParameters: [String: AnyObject], handler: @escaping (_ arrayOfImageURLs: [String])-> Void) {
        
        // TODO: Make request to Flickr!
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        DispatchQueue.global(qos: .userInteractive).async {
            let task =  session.dataTask(with: request) { (data, response, error)  in
                var arrayOfImageURLs = [String]()
                var jsonObject: [String:AnyObject]
                if error == nil {
                    do {
                        jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                        if let photosObject = jsonObject["photos"] as? [String: AnyObject] {
                            if let photoArray = photosObject["photo"] as? [AnyObject] {
                                for photo in photoArray {
                                    if let photoURL = photo["url_m"] as? String{
                                        arrayOfImageURLs.append(photoURL)
                                    }
                                }
                                DispatchQueue.main.async {
                                    handler(arrayOfImageURLs)
                                }
                                
                            }
                            
                        }
                    }
                    catch {
                        print("Could not parse data as JSON")
                    }
                }
                else {
                    print(error!.localizedDescription)
                }
            }
            task.resume()
            
        }
    }
    // MARK: Search By Latitude and Longitude
    
    func searchPinCoordinate(coordinate: CLLocationCoordinate2D, handler: @escaping (_ data: [String])-> Void) {
        
        if (isValueInRange(coordinate.latitude, min: Constants.BoundingBox.BoundingBoxLatitudeRange.0, max: Constants.BoundingBox.BoundingBoxLatitudeRange.1) && isValueInRange(coordinate.longitude, min: Constants.BoundingBox.BoundingBoxLongitudeRange.0, max: Constants.BoundingBox.BoundingBoxLongitudeRange.1)) {
            let methodParameters: [String: String] =
                [Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
                 Constants.FlickrParameterKeys.ApiKey:Constants.FlickrParameterValues.ApiKey,
                 
                 
                 Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL,
                 Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat,
                 Constants.FlickrParameterKeys.NoJSONCallBack:Constants.FlickrParameterValues.DisableJSONCallBack,
                 Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch,
                 Constants.FlickrParameterKeys.BoundingBox: bboxValues(coordinate: coordinate),
                 Constants.FlickrParameterKeys.PerPage:Constants.FlickrParameterValues.NumberOfImagePerPage,
                 Constants.FlickrParameterKeys.Page: Constants.pageNumber()]
            
            
            getFlickrImages(methodParameters as [String: AnyObject]) { (data) in
                DispatchQueue.main.async {
                    handler(data)
                }
            }
        }
        else {
            print("Latitude between -90 to 90 and Longitude between -180 to 180.")
        }
    }
    
    
    // MARK: Functions for search
    
    func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
    func bboxValues(coordinate: CLLocationCoordinate2D) -> String {
        
        var latMin = 0.0
        var latMax = 0.0
        var lonMin = 0.0
        var lonMax = 0.0
        
        
        let latDouble = coordinate.latitude
        latMin = latDouble - Constants.BoundingBox.BoundingBoxHalfHeight
        latMax = latDouble + Constants.BoundingBox.BoundingBoxHalfHeight
        latMin = max(Constants.BoundingBox.BoundingBoxLongitudeRange.0, latMin)
        latMax = min(Constants.BoundingBox.BoundingBoxLatitudeRange.1, latMax)
        
        
        let lonDouble = coordinate.longitude
        lonMin = lonDouble - Constants.BoundingBox.BoundingBoxHalfWidth
        lonMax = lonDouble + Constants.BoundingBox.BoundingBoxHalfWidth
        lonMin = max(Constants.BoundingBox.BoundingBoxLongitudeRange.0, lonMin)
        lonMax = min(Constants.BoundingBox.BoundingBoxLongitudeRange.1, lonMax)
        
        return "\(lonMin),\(latMin),\(lonMax),\(latMax)"
    }
    
    // Create a url from parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters! {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

