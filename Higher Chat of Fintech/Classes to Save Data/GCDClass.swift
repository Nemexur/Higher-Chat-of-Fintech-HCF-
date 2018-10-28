//
//  GCDDataManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

class GCDDataManager: SavingDataProtocol {
    var imageToSave: UIImage? = UIImage()
    var checkImage: UIImage = UIImage()
    var profileName: String? = String()
    var profileDescription: String? = String()
    var profileNameChecker: String = String()
    var profileDescriptionChecker: String = String()
    var errorFunction: (() -> ())?
    var completion: (() -> ())?
    var buttonsAndIndicatorAppearance: (() -> ())?
    
    var imageToDeliver: UIImage?
    var profileNameToDeliver: String?
    var profileDescriptionToDeliver: String?
    
    init(imageToSave: UIImage?, checkImage: UIImage, profileName: String?, profileDescription: String?, profileNameChecker: String, profileDescriptionChecker: String, errorFunction: @escaping() -> (), completion: @escaping () -> (), buttonsAndIndicatorAppearance: @escaping () -> ()) {
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
    
    init() { }
    
    func saveData() {
        let queue = DispatchQueue.global(qos: .background)
        let workItem = DispatchWorkItem {
            self.saveImageViaFileManager()
            self.saveNewProfileInformation()
        }
        queue.async(execute: workItem)
        workItem.notify(queue: DispatchQueue.main) {
            guard let completionfunction = self.completion,
                let buttonsAndIndicatorAlpha = self.buttonsAndIndicatorAppearance
                else { return }
            completionfunction()
            buttonsAndIndicatorAlpha()
        }
    }
    
    //MARK: - Saving Data
    
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
                DispatchQueue.main.async {
                    guard let errorfunction = self.errorFunction,
                        let buttonsAndIndicatorAlplha = self.buttonsAndIndicatorAppearance
                        else { return }
                    errorfunction()
                    buttonsAndIndicatorAlplha()
                }
            }
        }
    }
    
    private func saveNewProfileInformation() {
        let defaults = UserDefaults.standard
        if profileName == profileNameChecker && profileDescription != profileDescriptionChecker {
            defaults.set(profileDescription, forKey: "ProfileDescription")
        }
        else if profileName != profileNameChecker && profileDescription == profileDescriptionChecker {
            defaults.set(profileName, forKey: "ProfileName")
        }
        else if profileName != profileNameChecker && profileDescription != profileDescriptionChecker {
            defaults.set(profileName, forKey: "ProfileName")
            defaults.set(profileDescription, forKey: "ProfileDescription")
        }
    }
    
    //MARK: - Work With FileManager
    
    func getUserDataFromFileManager() -> (profileNameText: String?, profileDescriptionText: String?, profileImage: UIImage?){
        let defaults = UserDefaults.standard
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
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
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return (profileNameToDeliver, profileDescriptionToDeliver, imageToDeliver)
    }
    
    //MARK: - Getting Image
    
    private func getImage() -> UIImage? {
        //Document Directory
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        //Get Certain Data From Document Directory
        let fileManager = FileManager.default
        let imagePath = (documentsDirectory as NSString).appendingPathComponent("profileImage.jpg")
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)
        } else {
            DispatchQueue.main.async {
                guard let errorfunction = self.errorFunction,
                    let buttonsAndIndicatorAlplha = self.buttonsAndIndicatorAppearance
                    else { return }
                errorfunction()
                buttonsAndIndicatorAlplha()
            }
            return nil
        }
    }
}
