//
//  CoreDataStack.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

private struct CoreDataModelsInformation {
    static let modelName: String = "ModelForCoreData"
    static let coreDataExtension: String = "momd"
    static let storePathName: String = "AppUser.sqlite"

    private init() { }
}

final class CoreDataStack: ICoreDataStack {
    //Main Context
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateSaveManagedObjectContext
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    //Private Context which receives New Data
    lazy var privateNewDataManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.mainManagedObjectContext
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    //Private Context which saves data
    private lazy var privateSaveManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    //Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: CoreDataModelsInformation.modelName, withExtension: CoreDataModelsInformation.coreDataExtension)
            else {
                print("Error with modelURL")
                return nil }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            else {
                print("Error with managedObjectModel")
                return nil }
        return managedObjectModel
    }()

    //StoreURL for Persistent Store
    private var storeURL: URL {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectoryURL.appendingPathComponent(CoreDataModelsInformation.storePathName)
        return url
    }

    //Persistent Store
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
        } catch {
            print("Error with persistentStoreCoordinator")
        }
        return persistentStoreCoordinator
    }()

    //Perform Saving
    func saveChanges(context: NSManagedObjectContext, _ completionIfErrorHandler: (() -> Void)?, _ completionIfSuccessHandler: (() -> Void)?) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    OperationQueue.main.addOperation {
                        completionIfErrorHandler?()
                    }
                }

                if let parentContext = context.parent {
                    self?.saveChanges(context: parentContext, completionIfErrorHandler, completionIfSuccessHandler)
                }
                OperationQueue.main.addOperation {
                    completionIfSuccessHandler?()
                }
            }
        } else {
            print("Context has no changes")
        }
    }
}
