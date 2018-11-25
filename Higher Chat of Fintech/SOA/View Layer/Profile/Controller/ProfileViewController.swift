//
//  ProfileViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 27/09/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

// MARK: - Identifiers
private let imagesPickerSegueID = "ShowImagesPicker"

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ProfileModelDelegate, SelectedImageDelegate {
    // MARK: - IBOutlets

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
    @IBOutlet var coreDataButton: UIButton!
    @IBOutlet var stackViewWithSavingButtons: UIStackView!
    @IBOutlet var operationButton: UIButton!
    @IBOutlet var topConstraintForKeyboardAppearance: NSLayoutConstraint!
    @IBOutlet var bottomConstraintSavingButtons: NSLayoutConstraint!
    @IBOutlet var savingIndicator: UIActivityIndicatorView!

    // MARK: - Declared Image Pickers

    private struct ImagePickers {
        lazy var cameraImagePicker = UIImagePickerController()
        lazy var photolibraryImagePicker = UIImagePickerController()

        init() { }
    }

    // MARK: - Values for CornerRadius

    private struct CornerRadiusDefinition {
        static let profileImageAndEditProfileImageButton = 35
        static let editAndSaveButton = 10
        static let topBarProfileView = 10
        static let OperationAndGCDButtonCorner = 10
        static let topBarEditViewCorner = 10

        private init() { }
    }
    // MARK: - Variables for Saving, Fetching, Displaying Data
    private var datasource: ProfileDisplayModel?
    var profileModel: IProfileModel?
    fileprivate var appUser: AppUser?

    // MARK: - Overrided UIViewController Functions

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //logIfEnabled("\(editButton.frame)")
        //Произошла ошибка так, как мы пытаемся раскрыть значение, которое является на данный момент nil.
    }

    private var imagePickers: ImagePickers = ImagePickers()

    private var editModeIsAvailable: Bool = true

    private var saveDataHandler: ISavingData?

    private let textLimit: Int = 70
    // MARK: - Data Checker

    private var imageChecker: UIImage = UIImage()
    private var profileNameChecker: String = String()
    private var profileDescriptionChecker: String = String()

    // MARK: - Overrided UIViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        profileModel?.delegate = self
        configureImagePickers()
        setupBordersForImagesAndButtons()
        setupNotifications()
        setupViewElements()
        appUser = profileModel?.fetchAppUserData()
        //FIXME: - Uncomment if you need Operation saving
        //FIXME: - To Check Different Data Methods Uncomment/Comment a line
//        profileModel?.fetchUserDataViaOperation()
        setupGestures()
        addingTargetsToElements()
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
    }

    override func viewDidAppear(_ animated: Bool) {
        logIfEnabled("\nFrame of EditButton: \(editButton.frame) in ---\(#function)---\n")
        //Значение editButton.frame отличается в этой функции от значения editButton.frame в viewDidLoad, так как во время вызова editButton.frame в viewDidLoad значания
        //frame соответствует значению, которое было установлено в самом StoryBoard.
        //В viewDidAppear происходит установка того frame, который нам нужен в соответствии с устройством.
    }
    // MARK: - Delegate Functions
    func setup(datasource: ProfileDisplayModel) {
        self.datasource = datasource
        if let image = self.datasource?.image {
            self.profileImage.image = image
            self.imageChecker = image
        }
        if let name = self.datasource?.name {
            self.profileName.text = name
            self.profileNameChecker = name
            self.textFieldProfileName.text = name
        } else {
            self.textFieldProfileName.text = self.profileName.text
            self.profileNameChecker = self.profileName.text ?? ""
        }
        if let description = self.datasource?.description {
            self.profileDescription.text = description
            self.profileDescriptionChecker = description
            self.textViewProfileDescription.text = description
            self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
        } else {
            self.textViewProfileDescription.text = self.profileDescription.text
            self.profileDescriptionChecker = self.profileDescription.text ?? ""
            self.textViewCharacterCounter.text = "\(self.textLimit - self.textViewProfileDescription.text.count)"
        }
    }
    func show(error message: String) {
        print("Error: \(message)")
    }
    func didPickImage(image: UIImage?) {
        profileImage.image = image
        buttonsAvailability(coreDataButton, availability: true)
        //FIXME: - Uncomment if you need Operation saving
//        buttonsAvailability(operationButton, availability: true)
    }
    // MARK: - Additional Functions

    @objc private func hideKeyBoard() {
        textFieldProfileName.resignFirstResponder()
        textViewProfileDescription.resignFirstResponder()
    }
    private func setupGestures() {
        let tapToHideKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapToHideKeyboard)
    }
    private func addingTargetsToElements() {
        textFieldProfileName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    private func setupViewElements() {
        profileName.text = nil
        profileDescription.text = nil
        textFieldProfileName.text = nil
        textViewProfileDescription.text = nil
        textViewCharacterCounter.text = "\(textLimit)"
    }

    private func successCompletionHandler() {
        finishedSavingDataAlert()
        buttonsAvailability(self.operationButton, availability: false)
        buttonsAvailability(self.editButton, availability: true)
        savingIndicator.stopAnimating()
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
            self.bottomConstraintSavingButtons.constant = keyboardRect.height
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.topConstraintForKeyboardAppearance.constant = 6
            self.bottomConstraintSavingButtons.constant = 6
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    private func setupBordersForImagesAndButtons() {
        editProfileImageButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.profileImageAndEditProfileImageButton)
        editButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.editAndSaveButton)
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1
        coreDataButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.editAndSaveButton)
        coreDataButton.layer.borderColor = UIColor.black.cgColor
        coreDataButton.layer.borderWidth = 1
        operationButton.layer.cornerRadius = CGFloat(CornerRadiusDefinition.OperationAndGCDButtonCorner)
        operationButton.layer.borderColor = UIColor.black.cgColor
        operationButton.layer.borderWidth = 1
        profileImage.layer.cornerRadius = CGFloat(CornerRadiusDefinition.profileImageAndEditProfileImageButton)
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 1
        profileImage.clipsToBounds = true
        topBarProfileView.layer.cornerRadius = CGFloat(CornerRadiusDefinition.topBarProfileView)
        topBarProfileView.layer.borderColor = UIColor.black.cgColor
        topBarProfileView.layer.borderWidth = 1
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if profileNameChecker != textField.text {
            buttonsAvailability(coreDataButton, availability: true)
            //FIXME: - Uncomment if you need Operation saving
//            buttonsAvailability(operationButton, availability: true)
        }
    }

    // MARK: - Configured ImagePickers

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

    // MARK: - Button Actions

    @IBAction func importImageViaEditProfileImageButton(_ sender: Any) {
        hideKeyBoard()
        editProfileImageCodeAlert()
    }

    @IBAction func showEditViewController(_ sender: Any) {
        if editModeIsAvailable {
            displayEditMode()
            buttonsAvailability(coreDataButton, availability: false)
            //FIXME: - Uncomment if you need Operation saving
//            buttonsAvailability(operationButton, availability: false)
        } else {
            hideEditMode()
            hideKeyBoard()
            appUser = profileModel?.fetchAppUserData()
            if appUser?.currentUser?.userImage == nil {
                profileImage.image = #imageLiteral(resourceName: "ProfileImage")
            }
            //FIXME: - Uncomment if you need Operation saving
            //FIXME: - To Check Different Saving Methods Uncomment/Comment a line
//            profileModel?.fetchUserDataViaOperation()
        }
    }

    @IBAction func saveViacoreDataButton(_ sender: Any) {
        hideKeyBoard()
        coreDataSaving()
    }

    @IBAction func saveViaOperaionButton(_ sender: Any) {
        hideKeyBoard()
        operationSaving()
    }
    // MARK: - Unwind Segues to this ViewController
    @IBAction func unwindToProfileFromImages (_ sender: UIStoryboardSegue) { }
    // MARK: - Prepare For Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imagesPickerSegueID {
            guard let imagesController = segue.destination as? ImagesViewController else { return }
            setupImagesViewControllerElements(imagesController)
        }
    }
    // MARK: - Setup ViewControllers for Segues
    private func setupImagesViewControllerElements(_ imagesController: ImagesViewController) {
        guard let networkManger = profileModel?.networkManager else { return }
        let imagesModel: IImagesModel = ImagesModel(networkManager: networkManger)
        imagesController.imagesModel = imagesModel
        imagesController.view.backgroundColor = self.view.backgroundColor
        imagesController.imagesCollectionView.backgroundColor = self.view.backgroundColor
        imagesController.delegate = self
    }

    // MARK: - Alerts

    private func editProfileImageCodeAlert() {

        let alert = UIAlertController(title: "Image", message: "Import an image from", preferredStyle: .actionSheet)

        //Gallery Action
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [unowned self] (_) in

            self.present(self.imagePickers.photolibraryImagePicker, animated: true, completion: nil)
        }
        alert.addAction(galleryAction)

        //Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [unowned self] (_) in

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(self.imagePickers.cameraImagePicker, animated: true, completion: nil)
            } else { print("\n-----Camera is not available-----\n") }

        }
        alert.addAction(cameraAction)
        //Load Images Action
        let loadImagesAction = UIAlertAction(title: "Load", style: .default) { [unowned self] (_) in
            self.performSegue(withIdentifier: imagesPickerSegueID, sender: nil)
        }
        alert.addAction(loadImagesAction)

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
        let repeatAction = UIAlertAction(title: "Repeat", style: .default) { [unowned self] (_) in
            self.operationSaving()
        }

        alert.addAction(repeatAction)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Functions for Saving Buttons

    private func coreDataSaving() {
        buttonsAvailability(coreDataButton, availability: false)
        if appUser == nil {
            guard let context = profileModel?.getContextToSaveNewData()
                else { return }
            let newAppUser = AppUser.insertAppUser(into: context)
            newAppUser?.currentUser?.isOnline = true
            if profileImage.image != imageChecker {
                let imageData = profileImage.image?.jpegData(compressionQuality: 0.5)
                newAppUser?.currentUser?.userImage = imageData
            }
            if textFieldProfileName.text == profileNameChecker && textViewProfileDescription.text != profileDescriptionChecker {
                newAppUser?.currentUser?.userDescription = textViewProfileDescription.text
            } else if textFieldProfileName.text != profileNameChecker && textViewProfileDescription.text == profileDescriptionChecker {
                newAppUser?.currentUser?.userName = textFieldProfileName.text
            } else if textFieldProfileName.text != profileNameChecker && textViewProfileDescription.text != profileDescriptionChecker {
                newAppUser?.currentUser?.userDescription = textViewProfileDescription.text
                newAppUser?.currentUser?.userName = textFieldProfileName.text
            }
            profileModel?.saveNewData(completionIfError: { [unowned self] in self.errorsOccurredAlert() }) { [unowned self] in self.successCompletionHandler() }
        } else {
            if profileImage.image != imageChecker {
                let imageData = profileImage.image?.jpegData(compressionQuality: 0.5)
                profileModel?.updateDataAppUser(isOnline: nil, userName: nil, userDescription: nil, userImage: imageData, completionIfError: { [unowned self] in self.errorsOccurredAlert() }) { [unowned self] in self.successCompletionHandler() }
            }
            if textFieldProfileName.text == profileNameChecker && textViewProfileDescription.text != profileDescriptionChecker {
                profileModel?.updateDataAppUser(isOnline: nil, userName: nil, userDescription: textViewProfileDescription.text, userImage: nil, completionIfError: { [unowned self] in self.errorsOccurredAlert() }) { [unowned self] in self.successCompletionHandler() }
            } else if textFieldProfileName.text != profileNameChecker && textViewProfileDescription.text == profileDescriptionChecker {
                profileModel?.updateDataAppUser(isOnline: nil, userName: textFieldProfileName.text, userDescription: nil, userImage: nil, completionIfError: { [unowned self] in self.errorsOccurredAlert() }) { [unowned self] in self.successCompletionHandler() }
            } else if textFieldProfileName.text != profileNameChecker && textViewProfileDescription.text != profileDescriptionChecker {
                profileModel?.updateDataAppUser(isOnline: nil, userName: textFieldProfileName.text, userDescription: textViewProfileDescription.text, userImage: nil, completionIfError: { [unowned self] in self.errorsOccurredAlert() }) { [unowned self] in self.successCompletionHandler() }
            }
        }
    }

    private func operationSaving() {
        buttonsAvailability(operationButton, availability: false)
        buttonsAvailability(editButton, availability: false)
        savingIndicator.startAnimating()
        profileModel?.saveNewDataViaOperation(imageToSave: profileImage.image, checkImage: imageChecker, profileName: textFieldProfileName.text, profileDescription: textViewProfileDescription.text, profileNameChecker: profileNameChecker, profileDescriptionChecker: profileDescriptionChecker, errorFunction: { [unowned self] in self.errorsOccurredAlert() }, completion: { [unowned self] in self.finishedSavingDataAlert() }) { [unowned self] in
            self.buttonsAvailability(self.operationButton, availability: false)
            self.buttonsAvailability(self.editButton, availability: true)
            self.savingIndicator.stopAnimating()
        }
    }

    // MARK: - ImagePicker Delegates

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            buttonsAvailability(coreDataButton, availability: true)
            //FIXME: - Uncomment if you need Operation saving
//            buttonsAvailability(operationButton, availability: true)
        } else {
            errorsOccurredAlert()
        }
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
        print("----- ProfileViewController has been deinitialized -----")
        self.removeFromParent()
    }

    // MARK: - Functions to Hide/Display Edit Mode

    private func displayEditMode() {
        editModeIsAvailable.toggle()
        editProfileImageButton.isHidden = false
        profileName.isHidden = true
        profileDescription.isHidden = true
        textFieldProfileName.isHidden = false
        textViewProfileDescription.isHidden = false
        textViewCharacterCounter.isHidden = false
        topBarTitle.text = "Edit"
        editButton.setTitle("Cancel", for: .normal)
        editButton.setTitleColor(UIColor.red, for: .normal)
        coreDataButton.isHidden = false
        //FIXME: - Uncomment if you need Operation saving
//        stackViewWithSavingButtons.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.profileName.alpha = 0
            self.profileDescription.alpha = 0
            self.coreDataButton.alpha = 1
            //FIXME: - Uncomment if you need Operation saving
//            self.stackViewWithSavingButtons.alpha = 1
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
            self.coreDataButton.alpha = 0
            //FIXME: - Uncomment if you need Operation saving
//            self.stackViewWithSavingButtons.alpha = 0
        }
        topBarTitle.text = "Profile"
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(UIColor.black, for: .normal)
        coreDataButton.isHidden = true
        //FIXME: - Uncomment if you need Operation saving
//        stackViewWithSavingButtons.isHidden = true
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
            buttonsAvailability(coreDataButton, availability: true)
            //FIXME: - Uncomment if you need Operation saving
//            buttonsAvailability(operationButton, availability: true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= textLimit
    }
}
