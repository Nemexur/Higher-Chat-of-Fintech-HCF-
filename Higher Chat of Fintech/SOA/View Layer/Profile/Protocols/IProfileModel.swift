//
//  IProfileModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol IProfileModel: class {
    var delegate: ProfileModelDelegate? { get set }
    var storageManager: IStorageManager { get }
    var operationManager: ISavingData { get set }
    func getContextToSaveNewData() -> NSManagedObjectContext?
    func fetchAppUserData() -> AppUser?
    func fetchUserDataViaOperation()
    func saveNewData(completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?)
    func saveNewDataViaOperation(imageToSave: UIImage?, checkImage: UIImage, profileName: String?, profileDescription: String?, profileNameChecker: String, profileDescriptionChecker: String, errorFunction: @escaping() -> Void, completion: @escaping () -> Void, buttonsAndIndicatorAppearance: @escaping () -> Void)
    func updateDataAppUser(isOnline: Bool?, userName: String?, userDescription: String?, userImage: Data?, completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?)
}
