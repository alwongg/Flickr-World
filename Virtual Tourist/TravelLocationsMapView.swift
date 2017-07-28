//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/16/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var imageURLs: [String]?
    var photos: [Photo]?
    var imageDatas: [Data]?
    var touchCoordinate: CLLocationCoordinate2D?
    var pin: Pin?
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureMapView()
        mapView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        updateMapSpan()
        updateMapPins()
        
    }
    
    // MARK: Add longPressGesture Recognizer to mapView
    
    func configureMapView(){
        
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMap))
        mapView.addGestureRecognizer(longGestureRecognizer)
        longGestureRecognizer.minimumPressDuration = 0.5
    }
    
    func longPressOnMap(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            let touchPoint = gestureRecognizer.location(in: mapView)
            touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate!
            annotation.title = ""
            // Add annotation to the mapView
            mapView.addAnnotation(annotation)
            
            FlickrClient.sharedInstance().searchPinCoordinate(coordinate: touchCoordinate!) { (data) in
                self.imageURLs = data
                self.persistPinandPhoto(withCoordinate: self.touchCoordinate!)
            }
        }
        
    }
    
    // MARK: Update mapView on viewWillAppear method
    
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
        let context = AppDelegate.viewContext
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
    
    // MARK: Persist Functions
    
    func persistPinandPhoto(withCoordinate coordinate: CLLocationCoordinate2D)  {
        
        AppDelegate.persistentContainer.performBackgroundTask{ context in
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
    func printDatabaseStatistic() {
        let context = AppDelegate.viewContext
        context.perform {
            
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            
            if let result = try? context.fetch(request) {
                print("Photo Count: \(result.count)")
                for photo in result {
                    print("Photo.url: \(String(describing: photo.url))")
                }
                
            }

            if let pinCount = try? context.count(for: Pin.fetchRequest()) {
                print("Pin Count: \(pinCount)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if (identifier == "showPhotoViewController") {
                let photoAndMapVC = segue.destination as? PhotoAlbumViewController
                photoAndMapVC?.pin = pin
                photoAndMapVC?.photos = photos
            }
        }
    }
    
    //MARK: MKMapViewDelegate mapView annotation methods
    
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
  
    
    func lookForSelectedPin (view: MKAnnotationView, handler: @escaping((Pin?) -> Void)) {
        
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
            handler(selectedPin)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let regionSpanDictionary: [String : Any] = ["latitude": mapView.region.center.latitude, "longitude": mapView.region.center.longitude, "spanLatitude": mapView.region.span.latitudeDelta, "spanLongitude": mapView.region.span.longitudeDelta ]
        UserDefaults.standard.set(regionSpanDictionary, forKey:"region")
        
    }

}
    

