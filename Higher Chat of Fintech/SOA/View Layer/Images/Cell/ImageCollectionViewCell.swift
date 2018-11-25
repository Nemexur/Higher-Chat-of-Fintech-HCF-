//
//  ImageCollectionViewCell.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet var loadedImageForProfile: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    var imageURL: String? {
        didSet {
            loadedImageForProfile.image = #imageLiteral(resourceName: "ProfileImage")
            setImageWithImageURL()
        }
    }
    //Images Cache
    private let imageCache = NSCache<AnyObject, AnyObject>()
    //Set images
    private func setImageWithImageURL() {
        let session = URLSession.shared
        guard let imageURLString = imageURL else { return }
        let urlPath = URL(string: imageURLString)
        //Check cache
        if let imageFromCache = imageCache.object(forKey: imageURLString as AnyObject) as? UIImage {
            loadedImageForProfile.image = imageFromCache
            self.isUserInteractionEnabled = true
            return
        }
        if let url = urlPath {
            UIView.animate(withDuration: 0.5) {
                self.loadingIndicator.startAnimating()
                self.loadingIndicator.alpha = 1
            }
            session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, _: URLResponse?, error: Error?) in
                if error != nil {
                    return
                }
                OperationQueue.main.addOperation {
                    guard let imageData = data else { return }
                    if let image = UIImage(data: imageData) {
                        self?.imageCache.setObject(image, forKey: imageURLString as AnyObject)
                        if imageURLString == self?.imageURL {
                            self?.loadedImageForProfile.image = image
                            self?.isUserInteractionEnabled = true
                            self?.loadingIndicator.stopAnimating()
                        }
                    }
                }
            }).resume()
        }
    }
}
