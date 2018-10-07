//
//  ProfileViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 27/09/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var topBarProfileView: UIView!
    
    //MARK: - Declared Image Pickers
    
    private struct ImagePickers {
        lazy var cameraImagePicker = UIImagePickerController()
        lazy var photolibraryImagePicker = UIImagePickerController()
        
        
        init() { }
        
    }
    
    //MARK: - Values for CornerRadius
    
    private enum CornerRadiusDefinition {
        
        static let profileImageAndEditProfileImageButton = 35
        static let editButton = 10
        static let topBarProfileView = 10
        
    }
    
    //MARK: - Overrided UIViewController Functions
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //logIfEnabled("\(editButton.frame)")
        //Произошла ошибка так, как мы пытаемся раскрыть значение, которое является на данный момент nil.
    }
    
    private var imagePickers: ImagePickers = ImagePickers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePickers()
        setupBordersForImagesAndButtons()
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
        //Значение editButton.frame отличается в этой функции от значения editButton.frame в viewDidLoad, так как во время вызова editButton.frame в viewDidLoad значания
        //frame соответствует значению, которое было установлено в самом StoryBoard.
        //В viewDidAppear происходит установка того frame, который нам нужен в соответствии с устройством.
    }
    
    //MARK: - Setup Borders For Objects
    
    private func setupBordersForImagesAndButtons() {
        
        editProfileImageButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.profileImageAndEditProfileImageButton)
        editButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.editButton)
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1
        profileImage.layer.cornerRadius = CGFloat(CornerRadiusDefinition.profileImageAndEditProfileImageButton)
        profileImage.clipsToBounds = true
        topBarProfileView.layer.cornerRadius = CGFloat(CornerRadiusDefinition.topBarProfileView)
        topBarProfileView.layer.borderColor = UIColor.black.cgColor
        topBarProfileView.layer.borderWidth = 1
        
    }
    
    //MARK: - Configured ImagePickers
    
    private func configureImagePickers() {
        
        //Configure Settings for CameraImagePicker
        imagePickers.cameraImagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePickers.cameraImagePicker.sourceType = .camera
            imagePickers.cameraImagePicker.allowsEditing = false
            imagePickers.cameraImagePicker.cameraCaptureMode = .photo
            
        }

        //Configure Settings for PhotoLibraryImagePicker
        imagePickers.photolibraryImagePicker.delegate = self
        imagePickers.photolibraryImagePicker.sourceType = .photoLibrary
        imagePickers.photolibraryImagePicker.allowsEditing = false
        
    }
    
    //MARK: - Button Actions
    
    @IBAction func importImageViaEditProfileImageButton(_ sender: Any) {
        editProfileImageCodeAlert()
    }
    
    //MARK: - Importing Image From Camera/Gallery
    
    private func editProfileImageCodeAlert() {
        
        let alert = UIAlertController(title: "Image", message: "Import an image from", preferredStyle: .actionSheet)
        
        //Gallery Action
        let galleryAction = UIAlertAction(title: "Gallery", style: .default)
        { [unowned self] (_) in

            self.present(self.imagePickers.photolibraryImagePicker, animated: true, completion: nil)
        }
        alert.addAction(galleryAction)
        
        //Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        { [unowned self] (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(self.imagePickers.cameraImagePicker, animated: true, completion: nil)
            } else { print("\n-----Camera is not available-----\n") }
            
        }
        alert.addAction(cameraAction)
        
        //Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ImagePicker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
        }
        else {
            print("Unexpected error has occurred")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
