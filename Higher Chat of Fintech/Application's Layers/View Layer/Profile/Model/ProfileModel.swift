//
//  ProfileModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

struct ProfileDisplayModel {
    var name: String?
    var description: String?
    var image: UIImage?
    init(name: String?, description: String?, image: UIImage?) {
        self.name = name
        self.description = description
        self.image = image
    }
}

class ProfileModel: IProfileModel {
    weak var delegate: ProfileModelDelegate?
    var storageManager: IStorageManager
    var operationManager: ISavingData
    var networkManager: INetworkManager
    init(storageManager: IStorageManager, operationManager: ISavingData, networkManager: INetworkManager) {
        self.storageManager = storageManager
        self.operationManager = operationManager
        self.networkManager = networkManager
    }
    func fetchAppUserData() -> AppUser? {
        if let data = storageManager.readDataAppUser() {
            guard let imageData = data.currentUser?.userImage else {
                delegate?.show(error: "Unable to fetch Data from CoreData")
                return nil
            }
            delegate?.setup(datasource: ProfileDisplayModel(name: data.currentUser?.userName, description: data.currentUser?.userDescription, image: UIImage(data: imageData)))
            return data
        } else {
            delegate?.show(error: "Unable to fetch Data from CoreData")
            return nil
        }
    }
    func fetchUserDataViaOperation() {
        let fetchedData = operationManager.getUserDataFromFileManager()
        delegate?.setup(datasource: ProfileDisplayModel(name: fetchedData.profileNameText, description: fetchedData.profileDescriptionText, image: fetchedData.profileImage))
    }
    func updateDataAppUser(isOnline: Bool?, userName: String?, userDescription: String?, userImage: Data?, completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?) {
        storageManager.updateDataAppUser(isOnline: isOnline, userName: userName, userDescription: userDescription, userImage: userImage, completionIfError: completionIfError, completionIfSuccess: completionIfSuccess)
    }
    func saveNewData(completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?) {
        storageManager.saveDataAppUser(completionIfError: completionIfError, completionIfSuccess: completionIfSuccess)
    }
    func getContextToSaveNewData() -> NSManagedObjectContext? {
        if let contextToSaveNewData = storageManager.coreDataContextToSaveNewData {
            return contextToSaveNewData
        } else {
            delegate?.show(error: "Unable to get Context To Save New Data")
            return nil
        }
    }
    func saveNewDataViaOperation(imageToSave: UIImage?, checkImage: UIImage, profileName: String?, profileDescription: String?, profileNameChecker: String, profileDescriptionChecker: String, errorFunction: @escaping() -> Void, completion: @escaping () -> Void, buttonsAndIndicatorAppearance: @escaping () -> Void) {
        let saveData: ISavingData = OperationDataManager(imageToSave: imageToSave, checkImage: checkImage, profileName: profileName, profileDescription: profileDescription, profileNameChecker: profileNameChecker, profileDescriptionChecker: profileDescriptionChecker, errorFunction: errorFunction, completion: completion, buttonsAndIndicatorAppearance: buttonsAndIndicatorAppearance)
        let loadQueue = OperationQueue()
        if let operationDataManager = saveData as? OperationDataManager {
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
}
