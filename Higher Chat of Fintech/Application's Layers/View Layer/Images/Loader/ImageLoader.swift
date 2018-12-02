//
//  ImageLoader.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/12/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class ImageLoader: IImageLoader {
    var imageURL: String?
    weak var delegate: ImageLoaderDelegate?
    
    init(imageURL: String) {
        self.imageURL = imageURL
    }
    //Images Cache
    private let imageCache = NSCache<AnyObject, AnyObject>()
    //Set images
    func setImageWithImageURL() {
        OperationQueue.main.addOperation { self.delegate?.didSetImage(image: #imageLiteral(resourceName: "ProfileImage")) }
        let session = URLSession.shared
        guard let imageURLString = imageURL else { return }
        let urlPath = URL(string: imageURLString)
        //Check cache
        if let imageFromCache = imageCache.object(forKey: imageURLString as AnyObject) as? UIImage {
            OperationQueue.main.addOperation { self.delegate?.didSetImage(image: imageFromCache) }
            return
        }
        if let url = urlPath {
            OperationQueue.main.addOperation { self.delegate?.startIndicator() }
            if CheckInternet.connection() {
                performSessionDataTask(session: session, with: url, for: imageURLString)
            } else {
                OperationQueue.main.addOperation { self.delegate?.didReceiveError(error: "Error: 'No Internet Connection'") }
            }
        } else {
            OperationQueue.main.addOperation { self.delegate?.didReceiveError(error: "Error: Result Model doesn't conform to SendResult") }
        }
    }

    private func performSessionDataTask(session: URLSession, with url: URL, for imageURLString: String) {
        session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, _: URLResponse?, error: Error?) in
            if error != nil {
                return
            }
            OperationQueue.main.addOperation {
                guard let imageData = data else { return }
                if let image = UIImage(data: imageData) {
                    self?.imageCache.setObject(image, forKey: imageURLString as AnyObject)
                    if imageURLString == self?.imageURL {
                        self?.delegate?.didSetImage(image: image)
                        self?.delegate?.stopIndicator()
                    }
                }
            }
        }).resume()
    }
}
