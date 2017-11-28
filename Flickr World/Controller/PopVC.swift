//
//  PopVC.swift
//  Flickr World
//
//  Created by Alex Wong on 11/28/17.
//  Copyright © 2017 Alex Wong. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    var passedImage : UIImage!
    
    func initData(forImage image: UIImage){
        self.passedImage = image
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = passedImage
        
        addDoubleTap()
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dismissPopVC))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func dismissPopVC(){
        dismiss(animated: true, completion: nil)
    }
}
