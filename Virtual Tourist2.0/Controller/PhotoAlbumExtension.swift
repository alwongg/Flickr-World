//
//  PhotoAlbumExtension.swift
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

private let reuseIdentifier = "ImageCell"

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: CollectionViewDelegate and DataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let imageCell = cell as? CollectionViewCell {
            
            if let photoArray = photos, photos?.count != 0 {
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
                                                self.appDelegate.saveContext()
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
        
        if (collectionView.cellForItem(at: indexPath) as? CollectionViewCell) != nil{
            
            if let photo = photos?.remove(at: indexPath.row){
                DispatchQueue.main.async {
                    collectionView.deleteItems(at: [indexPath])
                }
                AppDelegate.viewContext.delete(photo)
                appDelegate.saveContext()
            }
        }
    }
}
