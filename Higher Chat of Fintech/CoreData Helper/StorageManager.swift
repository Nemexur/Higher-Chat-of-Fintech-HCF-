//
//  StorageManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    var coreDataStack: CoreDataStack?
    var coreDataContextToSaveNewData: NSManagedObjectContext?
    var coreDataMainContext: NSManagedObjectContext?
    var coreDataModel: NSManagedObjectModel?
    
    //MARK: - Elements for Singleton
    
    private static var sharedStorageManager: StorageManager = {
        let storageManager = StorageManager()
        
        return storageManager
    }()
    
    
    private init() {
        coreDataStack = CoreDataStack()
        coreDataContextToSaveNewData = coreDataStack?.privateNewDataManagedObjectContext
        coreDataMainContext = coreDataStack?.mainManagedObjectContext
        coreDataModel = coreDataContextToSaveNewData?.persistentStoreCoordinator?.managedObjectModel
    }
    
    
    //Getting StorageManager
    class func shared() -> StorageManager {
        return sharedStorageManager
    }
    
    
    //MARK: - CRUD Functions
    
    func saveDataAppUser(completionIfError: @escaping (() -> Void), completionIfSuccess: @escaping (() -> Void)) {
        guard let context = coreDataContextToSaveNewData
            else {
                print("Error with context in saveDataAppUser")
                completionIfError()
                return }
        coreDataStack?.saveChanges(context: context, completionIfError, completionIfSuccess)
    }
    
    func readDataAppUser() -> AppUser? {
        var appUserToFetch: AppUser?
        
        if let results = fetchAppUserData() {
            if results.count > 1 { fatalError("Multiple AppUsers") }
            if let fetchedUser = results.first {
                appUserToFetch = fetchedUser
            } else { return nil }
        }
        
        return appUserToFetch
    }
    
    func updateDataAppUser(isOnline: Bool?, userName: String?, userDescription: String?, userImage: Data?, completionIfError: @escaping (() -> Void), completionIfSuccess: @escaping (() -> Void)) {
        if let results = fetchAppUserData() {
            if results.count > 1 { completionIfError() }
            if let fetchedUser = results.first {
                guard let context = coreDataContextToSaveNewData
                    else {
                        print("Error with context in saveDataAppUser")
                        completionIfError()
                        return }
                let appUser = fetchedUser
                if userName != nil {
                    appUser.currentUser?.setValue(userName, forKey: "userName")
                }
                if userDescription != nil {
                    appUser.currentUser?.setValue(userDescription, forKey: "userDescription")
                }
                if userImage != nil {
                    appUser.currentUser?.setValue(userImage, forKey: "userImage")
                }
                if isOnline != nil {
                    appUser.currentUser?.setValue(isOnline, forKey: "isOnline")
                }
                coreDataStack?.saveChanges(context: context, completionIfError, completionIfSuccess)
            }
        }
    }
    
    func deleteDataAppUser() {
        if let results = fetchAppUserData() {
            if results.count > 1 { fatalError("Multiple AppUsers")}
            if let fetchedUser = results.first {
                guard let context = coreDataContextToSaveNewData
                    else { return }
                context.delete(fetchedUser)
            }
        }
    }
    
    //MARK: - Additional Functions
    
    private func fetchAppUserData() -> [AppUser]? {
        guard let context = coreDataContextToSaveNewData
            else {
                print("Error with ManagedObjectContext in StorageManager")
                return nil }
        guard let model = coreDataModel
            else {
                print("Error with ManagedObjectModel in StorageManager")
                return nil }
        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model)
            else {
                print("Error with FetchRequest to get AppUser")
                return nil }
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            fatalError("Error with fetching in Context")
        }
    }
}
