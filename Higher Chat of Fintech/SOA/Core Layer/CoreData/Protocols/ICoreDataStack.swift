//
//  ICoreDataStack.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 19/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol ICoreDataStack {
    var mainManagedObjectContext: NSManagedObjectContext { get set }
    var privateNewDataManagedObjectContext: NSManagedObjectContext { get set }
    var managedObjectModel: NSManagedObjectModel? { get set }
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get set }
    func saveChanges(context: NSManagedObjectContext, _ completionIfErrorHandler: (() -> Void)?, _ completionIfSuccessHandler: (() -> Void)?)
}
