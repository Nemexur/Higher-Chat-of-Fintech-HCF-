//
//  OperationDataManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

class OperationDataManager: Operation, ISavingData {
    private var imageToSave: UIImage? = UIImage()
    private var checkImage: UIImage = UIImage()
    private var profileName: String? = String()
    private var profileDescription: String? = String()
    private var profileNameChecker: String = String()
    private var profileDescriptionChecker: String = String()
    //Completion Handlers
    var errorFunction: (() -> Void)?
    var completion: (() -> Void)?
    var buttonsAndIndicatorAppearance: (() -> Void)?

    private var imageToDeliver: UIImage?
    private var profileNameToDeliver: String?
    private var profileDescriptionToDeliver: String?

    init(imageToSave: UIImage?, checkImage: UIImage, profileName: String?, profileDescription: String?, profileNameChecker: String, profileDescriptionChecker: String, errorFunction: @escaping() -> Void, completion: @escaping () -> Void, buttonsAndIndicatorAppearance: @escaping () -> Void) {
        super.init()
        self.imageToSave = imageToSave
        self.checkImage = checkImage
        self.profileName = profileName
        self.profileDescription = profileDescription
        self.profileNameChecker = profileNameChecker
        self.profileDescriptionChecker = profileDescriptionChecker
        self.errorFunction = errorFunction
        self.completion = completion
        self.buttonsAndIndicatorAppearance = buttonsAndIndicatorAppearance
    }

    override init() { super.init() }

    override func main() {
        saveData()
    }

    func saveData() {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperation {
            self.saveNewProfileInformation()
            self.saveImageViaFileManager()
        }
        operationQueue.waitUntilAllOperationsAreFinished()
    }

    // MARK: - Saving Data

    private func saveImageViaFileManager() {
        if imageToSave == checkImage {
            return
        } else {
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("profileImage.jpg")
            let imageData = imageToSave?.jpegData(compressionQuality: 0.5)
            if fileManager.createFile(atPath: path, contents: imageData, attributes: nil) {
                return
            } else {
                OperationQueue.main.addOperation {
                    guard let errorfunction = self.errorFunction,
                        let buttonsAndIndicatorAlpha = self.buttonsAndIndicatorAppearance
                        else { return }
                    errorfunction()
                    buttonsAndIndicatorAlpha()
                }
            }
        }
    }

    private func saveNewProfileInformation() {
        let defaults = UserDefaults.standard
        if profileName == profileNameChecker && profileDescription != profileDescriptionChecker {
            defaults.set(profileDescription, forKey: "ProfileDescription")
        } else if profileName != profileNameChecker && profileDescription == profileDescriptionChecker {
            defaults.set(profileName, forKey: "ProfileName")
        } else if profileName != profileNameChecker && profileDescription != profileDescriptionChecker {
            defaults.set(profileName, forKey: "ProfileName")
            defaults.set(profileDescription, forKey: "ProfileDescription")
        }
    }

    // MARK: - Work With FileManager

    func getUserDataFromFileManager() -> (profileNameText: String?, profileDescriptionText: String?, profileImage: UIImage?) {
        let defaults = UserDefaults.standard
        let operation = OperationQueue()
        operation.qualityOfService = .userInteractive
        operation.addOperation {
            if let image = self.getImage() {
                self.imageToDeliver = image
                self.checkImage = image
            }
            if let name = defaults.object(forKey: "ProfileName") as? String {
                self.profileNameToDeliver = name
                self.profileNameChecker = name
            }
            if let description = defaults.object(forKey: "ProfileDescription") as? String {
                self.profileDescriptionToDeliver = description
                self.profileDescriptionChecker = description
            }
        }
        operation.waitUntilAllOperationsAreFinished()
        return (profileNameToDeliver, profileDescriptionToDeliver, imageToDeliver)
    }

    // MARK: - Getting Image

    private func getImage() -> UIImage? {
        //Document Directory
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]

        //Get Certain Data From Document Directory
        let fileManager = FileManager.default
        let imagePath = (documentsDirectory as NSString).appendingPathComponent("profileImage.jpg")
        if fileManager.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)
        } else {
            OperationQueue.main.addOperation {
                guard let errorfunction = self.errorFunction,
                    let buttonsAndIndicatorAlpha = self.buttonsAndIndicatorAppearance
                    else { return }
                errorfunction()
                buttonsAndIndicatorAlpha()
            }
            return nil
        }
    }
}
