//
//  ConversationsListModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

struct ConversationsListCellDisplayModel {
    var identifier: String?
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool?
    var hasUnreadMessages: Bool?
    init(identifier: String?, name: String?, message: String?, date: Date?, online: Bool?, hasUnreadMessages: Bool?) {
        self.identifier = identifier
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
}

class ConversationsListModel: IConversationsListModel, CommunicationManagerDelegate {
    weak var delegate: ConversationsListModelDelegate?
    var storageManager: IStorageManager
    var operationManager: ISavingData
    var communicatorManager: ICommunicationManager
    var fetchedResultsController: NSFetchedResultsController<Conversation> = NSFetchedResultsController()
    init(storageManager: IStorageManager, communicatorManager: ICommunicationManager, operationManager: ISavingData) {
        self.storageManager = storageManager
        self.communicatorManager = communicatorManager
        self.operationManager = operationManager
        guard let context = self.storageManager.coreDataMainContext else { return }
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let sortDescriptorOnline = NSSortDescriptor(key: "isOnline", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOnline]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.communicatorManager.delegate = self
    }
    func fetchConversations() -> [Conversation]? {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            delegate?.show(error: "\(error), \(error.localizedDescription)")
        }
        if let conversations = storageManager.readDataConversation() {
            var dataSource: [ConversationsListCellDisplayModel] = []
            for conversation in conversations {
                dataSource.append(ConversationsListCellDisplayModel(identifier: conversation.conversationID, name: conversation.withUser?.userName, message: conversation.lastMessage?.text, date: conversation.date, online: conversation.isOnline, hasUnreadMessages: conversation.hasUnreadMessages))
            }
            delegate?.setup(datasource: dataSource)
            return conversations
        } else {
            delegate?.show(error: "Unable to fetch conversations in Model")
            return nil
        }
    }
    func saveNewData() {
        storageManager.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
    }
    func getContextToSaveNewData() -> NSManagedObjectContext? {
        if let contextToSaveNewData = storageManager.coreDataContextToSaveNewData {
            return contextToSaveNewData
        } else {
            delegate?.show(error: "Unable to get Context To Save New Data")
            return nil
        }
    }
    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        delegate?.receiveNewMessage(text: text, fromUser: fromUser, toUser: toUser)
    }
    func sendNewMessage(text: String, fromUser: String, toUser: String) {
        delegate?.sendNewMessage(text: text, fromUser: fromUser, toUser: toUser)
    }
    func newUser(userID: String, userName: String) {
        delegate?.newUser(userID: userID, userName: userName)
    }
    func lostUser(userID: String) {
        delegate?.lostUser(userID: userID)
    }
}
