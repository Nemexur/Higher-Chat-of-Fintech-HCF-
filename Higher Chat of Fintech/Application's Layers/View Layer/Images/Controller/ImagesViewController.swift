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
    private var emitterAnimationOnTap: IAnimationWithEmitterLayer?
    // MARK: - Overrided UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellSize()
        setupGestures()
        imagesModel?.delegate = self
        loadingIndicator.startAnimating()
        imagesModel?.loadImages()
    }
    // MARK: - Additional Functions
    @objc private func startAnimationOnTap(_ recongnizer: UILongPressGestureRecognizer) {
        emitterAnimationOnTap = TinkoffEmblemView()
        emitterAnimationOnTap?.emitterLayer = CAEmitterLayer()
        emitterAnimationOnTap?.emitterCell = CAEmitterCell()
        emitterAnimationOnTap?.rootLayer = CALayer()
        emitterAnimationOnTap?.recognizer = recongnizer
        emitterAnimationOnTap?.view = view
        switch recongnizer.state {
        case .began:
            emitterAnimationOnTap?.performAnimation()
        case .changed:
            emitterAnimationOnTap?.changeAnimationPosition()
        case .ended:
            emitterAnimationOnTap?.stopAnimation()
        case .cancelled:
            emitterAnimationOnTap?.stopAnimation()
        case .failed:
            emitterAnimationOnTap?.stopAnimation()
        default:
            return
        }
    }
    private func setupCellSize() {
        let numberOfCellsPerRow: CGFloat = 3
        if let layout = imagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = layout.scrollDirection == .vertical ? layout.minimumInteritemSpacing : layout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing - 25)/numberOfCellsPerRow
            layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }
    private func setupGestures() {
        let tapToAnimateTinkoffEmblem: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImagesViewController.startAnimationOnTap(_:)))
        view.addGestureRecognizer(tapToAnimateTinkoffEmblem)
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
        cell.imageLoader = ImageLoader(imageURL: loadedImages[indexPath.item].imageURL)
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
