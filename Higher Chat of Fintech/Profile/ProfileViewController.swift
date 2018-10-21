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
    @IBOutlet var profileDescription: UILabel!
    @IBOutlet weak var topBarProfileView: UIView!
    @IBOutlet var topBarTitle: UILabel!
    @IBOutlet var textFieldProfileName: UITextField!
    @IBOutlet var textViewProfileDescription: UITextView!
    @IBOutlet var textViewCharacterCounter: UILabel!
    @IBOutlet var stackViewWithSavingButtons: UIStackView!
    @IBOutlet var GCDButton: UIButton!
    @IBOutlet var OperationButton: UIButton!
    @IBOutlet var topConstraintForKeyboardAppearance: NSLayoutConstraint!
    @IBOutlet var bottomConstraintOfStackViewWithSavingButtons: NSLayoutConstraint!
    @IBOutlet var savingIndicator: UIActivityIndicatorView!
    
    //MARK: - Declared Image Pickers
    
    private struct ImagePickers {
        lazy var cameraImagePicker = UIImagePickerController()
        lazy var photolibraryImagePicker = UIImagePickerController()
        
        
        init() { }
    }
    
    //MARK: - Values for CornerRadius
    
    private struct CornerRadiusDefinition {
        static let profileImageAndEditProfileImageButton = 35
        static let editButton = 10
        static let topBarProfileView = 10
        static let OperationAndGCDButtonCorner = 10
        static let topBarEditViewCorner = 10
        
        
        private init() { }
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
    
    private var editModeIsAvailable: Bool = true
    
    private var saveDataHandler: SavingDataProtocol?
    
    private let textLimit: Int = 70
    
    //MARK: - Data Checker
    
    private var imageChecker: UIImage = UIImage()
    private var profileNameChecker: String = String()
    private var profileDescriptionChecker: String = String()
    
    //MARK: - Overrided UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImagePickers()
        setupBordersForImagesAndButtons()
        setupNotifications()
        
        profileName.text = nil
        profileDescription.text = nil
        
        //FIXME: - To Check Different Data Methods Uncomment/Comment a line
        //getDataGCD()
        getDataOperation()
        
        let tapToHideKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapToHideKeyboard)
        
        textFieldProfileName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
        //Значение editButton.frame отличается в этой функции от значения editButton.frame в viewDidLoad, так как во время вызова editButton.frame в viewDidLoad значания
        //frame соответствует значению, которое было установлено в самом StoryBoard.
        //В viewDidAppear происходит установка того frame, который нам нужен в соответствии с устройством.
    }
    
    //MARK: - Additional Functions
    
    @objc private func hideKeyBoard() {
        textFieldProfileName.resignFirstResponder()
        textViewProfileDescription.resignFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if profileNameChecker != textField.text {
            buttonsAvailability(GCDButton, availability: true)
            buttonsAvailability(OperationButton, availability: true)
            buttonsAvailability(editButton, availability: true)
        }
    }
    
    private func buttonsAvailability(_ button: UIButton, availability: Bool) {
        if !availability {
            button.isEnabled = false
            button.alpha = 0.66
        } else {
            button.isEnabled = true
            button.alpha = 1
        }
    }
    
    private func setupNotifications() {
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange (notification: NSNotification) {
        guard
            let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification {
            self.topConstraintForKeyboardAppearance.constant = -keyboardRect.height
            self.bottomConstraintOfStackViewWithSavingButtons.constant = keyboardRect.height
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.topConstraintForKeyboardAppearance.constant = 6
            self.bottomConstraintOfStackViewWithSavingButtons.constant = 6
            UIView.animate(withDuration: 0.5 , animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func setupBordersForImagesAndButtons() {
        
        editProfileImageButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.profileImageAndEditProfileImageButton)
        editButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.editButton)
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1
        GCDButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.OperationAndGCDButtonCorner)
        GCDButton.layer.borderColor = UIColor.black.cgColor
        GCDButton.layer.borderWidth = 1
        OperationButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.OperationAndGCDButtonCorner)
        OperationButton.layer.borderColor = UIColor.black.cgColor
        OperationButton.layer.borderWidth = 1
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
        hideKeyBoard()
        editProfileImageCodeAlert()
    }
    
    @IBAction func showEditViewController(_ sender: Any) {
        if editModeIsAvailable {
            displayEditMode()
            buttonsAvailability(GCDButton, availability: false)
            buttonsAvailability(OperationButton, availability: false)
        } else {
            hideEditMode()
            hideKeyBoard()
            //FIXME: - To Check Different Saving Methods Uncomment/Comment a line
            //getDataGCD()
            getDataOperation()
        }
    }
    
    @IBAction func saveViaGCDButton(_ sender: Any) {
        hideKeyBoard()
        GCDSaving()
    }
    
    @IBAction func saveViaOperaionButton(_ sender: Any) {
        hideKeyBoard()
        operationSaving()
    }

    //MARK: - Alerts
    
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
    
    private func finishedSavingDataAlert() {
        let alert = UIAlertController(title: "Data is saved successfully", message: nil, preferredStyle: .alert)
        
        //OK Action
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func errorsOccurredAlert() {
        let alert = UIAlertController(title: "Unexpected errors occurred", message: nil, preferredStyle: .alert)
        
        //OK Action
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OKAction)
        
        //Repeat Action
        let repeatAction = UIAlertAction(title: "Repeat", style: .default)
        { [unowned self] (_) in
            if self.saveDataHandler is OperationDataManager {
                self.operationSaving()
            }
            else if self.saveDataHandler is GCDDataManager {
                self.GCDSaving()
            }
        }
        
        alert.addAction(repeatAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Functions for Saving Buttons
    
    private func operationSaving() {
        buttonsAvailability(GCDButton, availability: false)
        buttonsAvailability(OperationButton, availability: false)
        buttonsAvailability(editButton, availability: false)
        savingIndicator.startAnimating()
        saveDataHandler = OperationDataManager(imageToSave: profileImage.image, checkImage: imageChecker, profileName: textFieldProfileName.text, profileDescription: textViewProfileDescription.text, profileNameChecker: profileNameChecker, profileDescriptionChecker: profileDescriptionChecker, errorFunction: { [unowned self] in self.errorsOccurredAlert() }, completion: { [unowned self] in self.finishedSavingDataAlert() })
        { [unowned self] in
            self.buttonsAvailability(self.GCDButton, availability: false)
            self.buttonsAvailability(self.OperationButton, availability: false)
            self.buttonsAvailability(self.editButton, availability: true)
            self.savingIndicator.stopAnimating()
        }
        let loadQueue = OperationQueue()
        if let operationDataManager = saveDataHandler as? OperationDataManager {
            operationDataManager.completionBlock = {
                OperationQueue.main.addOperation {
                    guard let completionfunction = operationDataManager.completion,
                        let buttonsAlpha = operationDataManager.buttonsAndIndicatorAppearance
                        else { return }
                    completionfunction()
                    buttonsAlpha()
                }
            }
            loadQueue.addOperation(operationDataManager)
        }
    }
    
    private func GCDSaving() {
        buttonsAvailability(GCDButton, availability: false)
        buttonsAvailability(OperationButton, availability: false)
        buttonsAvailability(editButton, availability: false)
        savingIndicator.startAnimating()
        saveDataHandler = GCDDataManager(imageToSave: profileImage.image, checkImage: imageChecker, profileName: textFieldProfileName.text, profileDescription: textViewProfileDescription.text, profileNameChecker: profileNameChecker, profileDescriptionChecker: profileDescriptionChecker, errorFunction: { [unowned self] in self.errorsOccurredAlert() }, completion: { [unowned self] in self.finishedSavingDataAlert() })
        { [unowned self] in
            self.buttonsAvailability(self.GCDButton, availability: false)
            self.buttonsAvailability(self.OperationButton, availability: false)
            self.buttonsAvailability(self.editButton, availability: true)
            self.savingIndicator.stopAnimating()
        }
        saveDataHandler?.saveData()
    }
    
    //MARK: - ImagePicker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            buttonsAvailability(GCDButton, availability: true)
            buttonsAvailability(OperationButton, availability: true)
            buttonsAvailability(editButton, availability: true)
        }
        else {
            errorsOccurredAlert()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("----- ProfileViewController has been deinitiolized -----")
        self.removeFromParent()
    }
    
    //MARK: - Get Data Via Certain Type Of Async
    
    private func getDataGCD() {
        saveDataHandler = GCDDataManager()
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            if let image = self.saveDataHandler?.getUserDataFromFileManager().profileImage {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                    self.imageChecker = image
                }
            }
            if let name = self.saveDataHandler?.getUserDataFromFileManager().profileNameText {
                DispatchQueue.main.async {
                    self.profileName.text = name
                    self.textFieldProfileName.text = name
                    self.profileNameChecker = name
                }
            } else {
                DispatchQueue.main.async {
                    self.textFieldProfileName.text = self.profileName.text
                    self.profileNameChecker = self.profileName.text ?? ""
                }
            }
            if let description = self.saveDataHandler?.getUserDataFromFileManager().profileDescriptionText {
                DispatchQueue.main.async {
                    self.profileDescription.text = description
                    self.textViewProfileDescription.text = description
                    self.profileDescriptionChecker = description
                    self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
                }
            } else {
                DispatchQueue.main.async {
                    self.textViewProfileDescription.text = self.profileDescription.text
                    self.profileDescriptionChecker = self.profileDescription.text ?? ""
                    self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
                }
            }
        }
    }
    
    private func getDataOperation() {
        saveDataHandler = OperationDataManager()
        let operation = OperationQueue()
        operation.qualityOfService = .userInteractive
        operation.addOperation {
            if let name = self.saveDataHandler?.getUserDataFromFileManager().profileNameText {
                OperationQueue.main.addOperation {
                    self.profileName.text = name
                    self.textFieldProfileName.text = name
                    self.profileNameChecker = name
                }
            } else {
                OperationQueue.main.addOperation {
                    self.textFieldProfileName.text = self.profileName.text
                    self.profileNameChecker = self.profileName.text ?? ""
                }
            }
            if let description = self.saveDataHandler?.getUserDataFromFileManager().profileDescriptionText {
                OperationQueue.main.addOperation {
                    self.profileDescription.text = description
                    self.textViewProfileDescription.text = description
                    self.profileDescriptionChecker = description
                    self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
                }
            } else {
                OperationQueue.main.addOperation {
                    self.textViewProfileDescription.text = self.profileDescription.text
                    self.profileDescriptionChecker = self.profileDescription.text ?? ""
                    self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
                }
            }
            if let image = self.saveDataHandler?.getUserDataFromFileManager().profileImage {
                OperationQueue.main.addOperation {
                    self.profileImage.image = image
                    self.imageChecker = image
                }
            }
        }
    }

    //MARK: - Additional Functions
    
    private func displayEditMode() {
        editModeIsAvailable.toggle()
        editProfileImageButton.isHidden = false
        profileName.isHidden = true
        profileDescription.isHidden = true
        textFieldProfileName.isHidden = false
        textViewProfileDescription.isHidden = false
        textViewCharacterCounter.isHidden = false
        topBarTitle.text = "Edit"
        editButton.setTitle("Отмена", for: .normal)
        editButton.setTitleColor(UIColor.red, for: .normal)
        stackViewWithSavingButtons.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.profileName.alpha = 0
            self.profileDescription.alpha = 0
            self.stackViewWithSavingButtons.alpha = 1
            self.editProfileImageButton.alpha = 1
            self.textFieldProfileName.alpha = 1
            self.textViewProfileDescription.alpha = 1
            self.textViewCharacterCounter.alpha = 1
        }
    }
    
    private func hideEditMode() {
        editModeIsAvailable.toggle()
        UIView.animate(withDuration: 0.5) {
            self.editProfileImageButton.alpha = 0
            self.textFieldProfileName.alpha = 0
            self.textViewProfileDescription.alpha = 0
            self.textViewCharacterCounter.alpha = 0
            self.profileName.alpha = 1
            self.profileDescription.alpha = 1
            self.stackViewWithSavingButtons.alpha = 0
        }
        topBarTitle.text = "Profile"
        editButton.setTitle("Редактировать", for: .normal)
        editButton.setTitleColor(UIColor.black, for: .normal)
        stackViewWithSavingButtons.isHidden = true
        profileName.isHidden = false
        profileDescription.isHidden = false
        textFieldProfileName.isHidden = true
        textViewProfileDescription.isHidden = true
        textViewCharacterCounter.isHidden = true
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewCharacterCounter.text = "\(textLimit - textView.text.count)"
        if profileDescriptionChecker != textViewProfileDescription.text {
            buttonsAvailability(GCDButton, availability: true)
            buttonsAvailability(OperationButton, availability: true)
            buttonsAvailability(editButton, availability: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= textLimit
    }
}
