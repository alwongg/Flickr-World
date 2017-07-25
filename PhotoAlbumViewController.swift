//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Alex Wong on 7/17/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreImage

private let reuseIdentifier = "ImageCell"

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Properties
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var photos: [Photo]?
    var pin: Pin?
    
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    
    @IBAction func refreshCollection(_ sender: Any) {
        let coordinate = CLLocationCoordinate2D(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!)
        for i in 0..<photos!.count {
            if let photo = photos?[i] {
                AppDelegate.viewContext.delete(photo)
            }
        }
        
        appDelegate?.saveContext()
        photos = [Photo]()
        
        FlickrClient.sharedInstance().searchPinCoordinate(coordinate: coordinate) { (imageURLs) in
            
            DispatchQueue.main.async {
                for imageURL in imageURLs {
                    let photoEntity = Photo(context: AppDelegate.viewContext, url: imageURL)
                    self.photos?.append(photoEntity)
                    photoEntity.connectArrayOfPhotosToPin(pin: self.pin!)
                    
                }
                
                self.appDelegate?.saveContext()
                self.collectionView.reloadData()
            }
            
        }
        
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPinOnMapView()
        
    }
    
    // MARK: Pin Function
    
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
    
    // MARK: UICollectionView setup with DataSource and Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photos?.count)!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let imageCell = cell as? CollectionViewCell {
            
            if let photoArray = photos, (photos?.count)! > 0 {
                if (indexPath.row < photoArray.count) {
                    if (photoArray[indexPath.row].image == nil) {
                        DispatchQueue.global(qos: .userInteractive).async {
                            let currentPhoto = photoArray[indexPath.row]
                            
                            AppDelegate.viewContext.perform {
                                if let photoURL = currentPhoto.url {
                                    if let url = URL(string: photoURL) {
                                        do {
                                            let data = try Data(contentsOf: url)
                                            
                                            DispatchQueue.main.async {
                                                imageCell.imageView.image = UIImage(data: data)
                                                currentPhoto.updateData(data: data)
                                                self.appDelegate?.saveContext()
                                            }
                                            
                                        }
                                        catch {
                                            print("Cannot get data")
                                        }
                                        
                                    }
                                }else {
                                    print("No URL or invalid")
                                }
                            }
                            
                            
                        }
                        
                    }
                    else {
                        imageCell.imageView.image = UIImage(data: photoArray[indexPath.row].image! as Data)
                    }
                }
            }
        }
        else {
            print("Cannot create cell")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? CollectionViewCell) != nil {
            
            if let photo = photos?.remove(at: indexPath.row){
                DispatchQueue.main.async {
                    collectionView.deleteItems(at: [indexPath])
                }
                
                AppDelegate.viewContext.delete(photo)
                appDelegate?.saveContext()
                
            }
            
        }
    }
    
    
    
}
