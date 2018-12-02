//
//  ConversationModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

struct ConversationCellDisplayModel {
    var message: String?
    init(message: String?) {
        self.message = message
    }
}

class ConversationModel: IConversationModel, CommunicationManagerDelegate {
    weak var delegate: ConversationModelDelegate?
    var communicatorManager: ICommunicationManager
    private let storageManager: IStorageManager
    private let conversationID: String
    var fetchedResultsController: NSFetchedResultsController<Message> = NSFetchedResultsController()
    init(storageManager: IStorageManager, communicatorManager: ICommunicationManager, conversationID: String) {
        self.storageManager = storageManager
        self.communicatorManager = communicatorManager
        self.conversationID = conversationID
        guard let context = self.storageManager.coreDataMainContext else { return }
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversation.conversationID = %@", self.conversationID)
        let sortDescriptor = NSSortDescriptor(key: "isIncoming", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.communicatorManager.delegate = self
    }
    func fetchMessages() -> [Message]? {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            delegate?.show(error: "\(error), \(error.localizedDescription)")
        }
        if let fetchedMessages = storageManager.readDataConversationMessages(conversationID: self.conversationID) {
            var dataSource: [ConversationCellDisplayModel] = []
            for message in fetchedMessages {
                dataSource.append(ConversationCellDisplayModel(message: message.text))
            }
            delegate?.setup(datasource: dataSource)
            return fetchedMessages
        } else {
            delegate?.show(error: "Unable to fetch messages in Model")
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
