//
//  IStorageManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol IStorageManager {
    //CoreData Elements
    var coreDataStack: ICoreDataStack? { get }
    var coreDataContextToSaveNewData: NSManagedObjectContext? { get }
    var coreDataMainContext: NSManagedObjectContext? { get }
    var coreDataModel: NSManagedObjectModel? { get }
    //Functions to work with CoreData
    func saveDataAppUser(completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?)
    func updateDataAppUser(isOnline: Bool?, userName: String?, userDescription: String?, userImage: Data?, completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?)
    func readDataAppUser() -> AppUser?
    func readDataConversation() -> [Conversation]?
    func readDataConversationMessages(conversationID: String) -> [Message]?
}
