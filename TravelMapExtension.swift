//
//  TravelMapExtension.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/28/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

extension TravelLocationsMapViewController: MKMapViewDelegate{
    
    // MARK: MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .blue
            
        }
        
        return pinView
    }
    
    // Segue to PhotoAlbumViewController when pin is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        imageDatas = [Data]()
        photos = [Photo]()
        lookForSelectedPin(view: view) { (selectedPin) in
            if let pin = selectedPin {
                self.pin = pin
                let context = AppDelegate.viewContext
                context.perform
                    {
                        let predicate = NSPredicate(format: "myPin = %@", self.pin!)
                        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                        request.predicate = predicate
                        if let result = try? context.fetch(request) {
                            DispatchQueue.main.async {
                                self.photos = result
                                
                                self.performSegue(withIdentifier: "showPhotoViewController", sender: self)
                                
                            }
                        }
                }
            }
        }
    }
    
    func lookForSelectedPin (view: MKAnnotationView, completionHandler: @escaping((Pin?) -> Void)) {
        
        let context = AppDelegate.viewContext
        var selectedPin: Pin?
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? context.fetch(request) {
            for pin in result {
                if (view.annotation?.coordinate.latitude == pin.latitude && view.annotation?.coordinate.longitude == pin.longitude) {
                    selectedPin = pin
                    break
                }
            }
            completionHandler(selectedPin)
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let regionSpanDictionary: [String : Any] =
            ["latitude": mapView.region.center.latitude,
             "longitude": mapView.region.center.longitude,
             "spanLatitude": mapView.region.span.latitudeDelta,
             "spanLongitude": mapView.region.span.longitudeDelta]
        UserDefaults.standard.set(regionSpanDictionary, forKey:"region")
    }
}
