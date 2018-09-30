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
    
    //MARK: - Declared Image Pickers
    
    private enum ImagePickers {
        
        static let cameraImagePicker = UIImagePickerController()
        static let photolibraryImagePicker = UIImagePickerController()
        
    }
    
    //MARK: - Values for CornerRadius
    
    private enum CornerRadiusDefinition {
        
        static let profileImageAndEditProfileImageButton = 35
        static let editButton = 10
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePickers()
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupBordersForImagesAndButtons()
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
        
    }
    
    //MARK: - Configured ImagePickers
    
    private func configureImagePickers() {
        
        //Configure Settings for CameraImagePicker
        ImagePickers.cameraImagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            ImagePickers.cameraImagePicker.sourceType = .camera
            ImagePickers.cameraImagePicker.allowsEditing = false
            ImagePickers.cameraImagePicker.cameraCaptureMode = .photo
            
        }

        //Configure Settings for PhotoLibraryImagePicker
        ImagePickers.photolibraryImagePicker.delegate = self
        ImagePickers.photolibraryImagePicker.sourceType = .photoLibrary
        ImagePickers.photolibraryImagePicker.allowsEditing = false
        
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

            self.present(ImagePickers.photolibraryImagePicker, animated: true, completion: nil)
        }
        alert.addAction(galleryAction)
        
        //Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        { [unowned self] (_) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(ImagePickers.cameraImagePicker, animated: true, completion: nil)
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
