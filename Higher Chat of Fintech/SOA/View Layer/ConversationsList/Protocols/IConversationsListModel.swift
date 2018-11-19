//
//  IConversationsListModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol IConversationsListModel: class {
    var delegate: ConversationsListModelDelegate? { get set }
    var storageManager: IStorageManager { get }
    var operationManager: ISavingData { get }
    var communicatorManager: ICommunicationManager { get set }
    var fetchedResultsController: NSFetchedResultsController<Conversation> { get set }
    func fetchConversations() -> [Conversation]?
    func saveNewData()
    func getContextToSaveNewData() -> NSManagedObjectContext?
}
