//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist2.0
//
//  Created by Alex Wong on 8/4/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class TravelLocationsMapViewController: UIViewController {
    
    // MARK: - Properties
    
    var imageURLs: [String]?
    var photos: [Photo]?
    var imageDatas: [Data]?
    var touchCoordinate: CLLocationCoordinate2D?
    var pin: Pin?
    let context = AppDelegate.viewContext
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureMapView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        updateMapSpan()
        updateMapPins()
        
    }
    
    // MARK: - Config MapView Gestures
    
    // Add Long Press Gesture to mapView on load
    func configureMapView(){
        
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMap))
        mapView.addGestureRecognizer(longGestureRecognizer)
        longGestureRecognizer.minimumPressDuration = 0.5
    }
    
    // Set Gesture as Long Press
    @objc func longPressOnMap(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
            let touchPoint = gestureRecognizer.location(in: mapView)
            touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate!
            annotation.title = ""
            
            // Add annotation to the mapView
            mapView.addAnnotation(annotation)
            
            // Call search method from FlickrClient
            FlickrClient.sharedInstance().searchPinCoordinate(coordinate: touchCoordinate!) { (data) in
                self.imageURLs = data
                self.persistenceOfPinAndPhoto(withCoordinate: self.touchCoordinate!)
            }
        }
    }
    
    // MARK: - Update mapView on viewWillAppear method
    
    func updateMapSpan() {
        
        // Update and save map span
        
        if let regionSpanDictionary = UserDefaults.standard.value(forKey: "region") as? [String: Any] {
            if let latitude = regionSpanDictionary["latitude"] as? CLLocationDegrees,
                let longitude = regionSpanDictionary["longitude"] as? CLLocationDegrees,
                let spanLatitude = regionSpanDictionary["spanLatitude"] as? CLLocationDegrees,
                let spanLongitude = regionSpanDictionary["spanLongitude"] as? CLLocationDegrees {
                var regionSpan = MKCoordinateRegion()
                regionSpan.center.latitude = latitude
                regionSpan.center.longitude = longitude
                regionSpan.span = MKCoordinateSpanMake(spanLatitude, spanLongitude)
                mapView.region = regionSpan
            }
        }
    }
    
    func updateMapPins() {
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? context.fetch(request) {
            var annotationsArray = [MKPointAnnotation]()
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.title = ""
                annotation.coordinate.latitude = pin.latitude
                annotation.coordinate.longitude = pin.longitude
                annotationsArray.append(annotation)
            }
            mapView.addAnnotations(annotationsArray)
        }
    }
    
    // MARK: - Persist Functions
    
    func persistenceOfPinAndPhoto(withCoordinate coordinate: CLLocationCoordinate2D)  {
        
        AppDelegate.persistentContainer.performBackgroundTask{
            context in
            let pinEntity = Pin(context: context, latitude: coordinate.latitude, longitude: coordinate.longitude)
            if let imageURLs = self.imageURLs {
                
                for imageURL in imageURLs {
                    let photoEntity = Photo(context: context, url: imageURL)
                    photoEntity.connectArrayOfPhotosToPin(pin: pinEntity)
                }
            }
            try? context.save()
            self.imageURLs?.removeAll()
            
        }
    }
    
    // MARK: - Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if (identifier == "showCollectionView") {
                let mapAndPhotoViewController = segue.destination as? PhotoAlbumViewController
                mapAndPhotoViewController?.pin = pin
                mapAndPhotoViewController?.photos = photos
            }
        }
    }
}

