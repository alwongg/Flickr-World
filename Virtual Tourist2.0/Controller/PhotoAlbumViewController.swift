//
//  PhotoViewController.swift
//  Virtual Tourist2.0
//
//  Created by Alex Wong on 8/4/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreImage

class PhotoAlbumViewController: UIViewController{
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var photos: [Photo]?
    var pin: Pin?
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPinOnMapView()
        
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        let coordinate = CLLocationCoordinate2D(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!)
        for i in 0..<photos!.count {
            if let photo = photos?[i] {
                AppDelegate.viewContext.delete(photo)
            }
        }
        
        appDelegate.saveContext()
        photos = [Photo]()
        
        FlickrClient.sharedInstance().searchPinCoordinate(coordinate: coordinate) { (imageURLs) in
            
            DispatchQueue.main.async {
                for imageURL in imageURLs {
                    let photoEntity = Photo(context: AppDelegate.viewContext, url: imageURL)
                    self.photos?.append(photoEntity)
                    photoEntity.connectArrayOfPhotosToPin(pin: self.pin!)
                }
                self.appDelegate.saveContext()
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Pin Function
    
    func setPinOnMapView() {
        
        print("Pin function initiated")
        let coordinate = CLLocationCoordinate2D(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!)
        
        // Create annotation
        let annotation = MKPointAnnotation()
        
        // Set coordinate to annotation
        annotation.coordinate = coordinate
        annotation.title = ""
        mapView.addAnnotation(annotation)
        
        let spanX = 2.0
        let spanY = 2.0
        var region = MKCoordinateRegion()
        region.center.latitude = (pin?.latitude)!
        region.center.longitude = (pin?.longitude)!
        region.span = MKCoordinateSpanMake(spanX, spanY)
        mapView.setRegion(region, animated: true)
        
    }
}
