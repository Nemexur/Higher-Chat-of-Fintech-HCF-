//
//  Conversation.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 06/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Conversation {
    static func insertConversation(into context: NSManagedObjectContext) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            return conversation
        } else { return nil }
    }

    static func fetchRequestConversation(model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        let templateName = "fetchConversation"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<Conversation>
            else {
                print("Error with Template: \(templateName)")
                return nil }
        return fetchRequest
    }
}
