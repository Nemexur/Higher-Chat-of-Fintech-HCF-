//
//  IConversationModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol IConversationModel: class {
    var delegate: ConversationModelDelegate? { get set }
    var communicatorManager: ICommunicationManager { get set }
    var fetchedResultsController: NSFetchedResultsController<Message> { get set }
    func fetchMessages() -> [Message]?
    func saveNewData()
    func getContextToSaveNewData() -> NSManagedObjectContext?
}
