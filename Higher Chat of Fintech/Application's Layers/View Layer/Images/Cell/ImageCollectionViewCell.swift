//
//  ImageCollectionViewCell.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, ImageLoaderDelegate {
    // MARK: - IBOutlets
    @IBOutlet var loadedImageForProfile: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    var imageLoader: IImageLoader? {
        didSet {
            imageLoader?.delegate = self
            imageLoader?.setImageWithImageURL()
        }
    }
    func didSetImage(image: UIImage) {
        if image == #imageLiteral(resourceName: "ProfileImage") {
            loadedImageForProfile.image = image
        } else {
            loadedImageForProfile.image = image
            self.isUserInteractionEnabled = true
        }
    }
    // MARK: - Delegate Functions
    func didReceiveError(error: String) {
        print(error)
    }
    
    func startIndicator() {
        UIView.animate(withDuration: 0.5) {
            self.loadingIndicator.startAnimating()
            self.loadingIndicator.alpha = 1
        }
    }
    
    func stopIndicator() {
        loadingIndicator.stopAnimating()
    }
}
