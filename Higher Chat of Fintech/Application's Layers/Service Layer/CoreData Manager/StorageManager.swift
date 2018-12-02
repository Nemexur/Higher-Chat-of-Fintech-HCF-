//
//  StorageManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

class StorageManager: IStorageManager {
    var coreDataStack: ICoreDataStack?
    var coreDataContextToSaveNewData: NSManagedObjectContext?
    var coreDataMainContext: NSManagedObjectContext?
    var coreDataModel: NSManagedObjectModel?

    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
        //Getting CoreData Elements
        self.coreDataContextToSaveNewData = self.coreDataStack?.privateNewDataManagedObjectContext
        self.coreDataMainContext = self.coreDataStack?.mainManagedObjectContext
        self.coreDataModel = coreDataContextToSaveNewData?.persistentStoreCoordinator?.managedObjectModel
    }

    // MARK: - CRUD Functions

    func saveDataAppUser(completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?) {
        guard let context = coreDataContextToSaveNewData
            else {
                print("Error with context in saveDataAppUser")
                completionIfError?()
                return }
        coreDataStack?.saveChanges(context: context, completionIfError, completionIfSuccess)
    }

    func saveDataAppUserInMain(completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?) {
        guard let context = coreDataMainContext
            else {
                print("Error with context in saveDataAppUserInMain")
                completionIfError?()
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

    //Fetch Conversations of AppUser
    func readDataConversation() -> [Conversation]? {
        return getFetchRequestData(Conversation.self, dataManager: self)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        do {
//            let results = try context.fetch(request)
//            return results
//        } catch {
//            print("Error in fetchRequest with certain ConversationID")
//            return nil
//        }
    }

    //Getting Messages From the certain Conversation
    func readDataConversationMessages(conversationID: String) -> [Message]? {
        if let results = fetchConversation(with: conversationID) {
            if results.count > 1 { fatalError("Multiple Conversations with same ID") }
            guard let messages = results.first?.messages?.array as? [Message]
                else {
                    print("Error in converting NSSet to [Message]")
                    return nil }
            return messages
        } else { return nil }
    }

    func updateDataAppUser(isOnline: Bool?, userName: String?, userDescription: String?, userImage: Data?, completionIfError: (() -> Void)?, completionIfSuccess: (() -> Void)?) {
        if let results = fetchAppUserData() {
            if results.count > 1 { completionIfError?() }
            if let fetchedUser = results.first {
                guard let context = coreDataContextToSaveNewData
                    else {
                        print("Error with context in saveDataAppUser")
                        completionIfError?()
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

    func deleteConversationInCoreData(_ conversation: Conversation) {
        guard let context = coreDataMainContext
            else { return }
        context.delete(conversation)
    }

    // MARK: - Additional Functions

    private func fetchAppUserData() -> [AppUser]? {
        return getFetchRequestData(AppUser.self, dataManager: self)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        guard let model = coreDataModel
//            else {
//                print("Error with ManagedObjectModel in StorageManager")
//                return nil }
//        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model)
//            else {
//                print("Error with FetchRequest to get AppUser")
//                return nil }
//        do {
//            let results = try context.fetch(fetchRequest)
//            return results
//        } catch {
//            fatalError("Error with fetching in Context")
//        }
    }

    private func fetchConversation(with conversationId: String) -> [Conversation]? {
        let fetchPredicate = NSPredicate(format: "conversationID = %@", conversationId)
         return getFetchRequestData(Conversation.self, dataManager: self, predicate: fetchPredicate)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        request.predicate = fetchPredicate
//        do {
//            let results = try context.fetch(request)
//            return results
//        } catch {
//            print("Error in fetchRequest with certain ConversationID")
//            return nil
//        }
    }

    private func fetchConversationWhereUserOnline() -> [Conversation]? {
        let fetchPredicate = NSPredicate(format: "withUser.isOnline = %@", NSNumber(booleanLiteral: true))
        return getFetchRequestData(Conversation.self, dataManager: self, predicate: fetchPredicate)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        request.predicate = fetchPredicate
//        do {
//            let results = try context.fetch(request)
//            return results
//        } catch {
//            print("Error in fetchRequest whereUserOnline")
//            return nil
//        }
    }

    private func fetchUser(with onlineAttribute: Bool) -> [User]? {
        let fetchPredicate = NSPredicate(format: "isOnline = %@", NSNumber(booleanLiteral: onlineAttribute))
        return getFetchRequestData(User.self, dataManager: self, predicate: fetchPredicate)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        let request: NSFetchRequest<User> = User.fetchRequest()
//        request.predicate = fetchPredicate
//        do {
//            let results = try context.fetch(request)
//            return results
//        } catch {
//            print("Error in fetchRequest with onlineAttribute")
//            return nil
//        }
    }

    private func fetchUser(with certainID: String) -> [User]? {
        let fetchPredicate = NSPredicate(format: "userID = %@", certainID)
        return getFetchRequestData(User.self, dataManager: self, predicate: fetchPredicate)
//        guard let context = coreDataContextToSaveNewData
//            else {
//                print("Error with ManagedObjectContext in StorageManager")
//                return nil }
//        let request: NSFetchRequest<User> = User.fetchRequest()
//        request.predicate = fetchPredicate
//        do {
//            let results = try context.fetch(request)
//            return results
//        } catch {
//            print("Error in fetchRequest with certainID")
//            return nil
//        }
    }
}
