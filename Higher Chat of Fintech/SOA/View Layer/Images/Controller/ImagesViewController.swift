//
//  ImagesViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController, ImagesModelDelegate {
    // MARK: - IBOutlets
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    // MARK: - Configurations for Cell
    struct ImageCellConfigurations {
        static let imageCell = "ImageCell"
        static let imageCellCorner: CGFloat = 10
        static let imageCellBorder: CGFloat = 0.5
        private init() { }
    }
    //Model
    var imagesModel: IImagesModel?
    fileprivate let imageNumber = 200
    fileprivate var loadedImages: [ImageCellDisplayModel] = []
    weak var delegate: SelectedImageDelegate?
    // MARK: - Overrided UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellSize()
        imagesModel?.delegate = self
        loadingIndicator.startAnimating()
        imagesModel?.loadImages()
    }
    // MARK: - Additional Functions
    private func setupCellSize() {
        let numberOfCellsPerRow: CGFloat = 3
        if let layout = imagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = layout.scrollDirection == .vertical ? layout.minimumInteritemSpacing : layout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing - 25)/numberOfCellsPerRow
            layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }
    // MARK: - Delegate Functions
    func didReceiveImages(displayModel: [ImageCellDisplayModel]) {
        loadedImages = displayModel
        loadingIndicator.stopAnimating()
        imagesCollectionView.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.imagesCollectionView.alpha = 1
        }
    }
    func didReceiveError(error: String) {
        print(error)
    }
    // MARK: - Deinitializer
    deinit {
        print("----- ImagesViewController has been deinitialized -----")
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellConfigurations.imageCell, for: indexPath) as? ImageCollectionViewCell
            else { return ImageCollectionViewCell() }
        configure(cell, at: indexPath)
        return cell
    }
    private func configure(_ cell: ImageCollectionViewCell, at indexPath: IndexPath) {
        cell.isUserInteractionEnabled = false
        cell.imageURL = loadedImages[indexPath.item].imageURL
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = ImageCellConfigurations.imageCellBorder
        cell.layer.cornerRadius = ImageCellConfigurations.imageCellCorner
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pickedImage = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            if pickedImage.isUserInteractionEnabled {
                 delegate?.didPickImage(image: pickedImage.loadedImageForProfile.image)
            }
        }
    }
}
