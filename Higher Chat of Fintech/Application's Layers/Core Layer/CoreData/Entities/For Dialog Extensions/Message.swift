//
//  Message.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 06/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Message {
    static func insertMessage(into context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            return message
        } else { return nil }
    }

    static func fetchRequestMessage(model: NSManagedObjectModel) -> NSFetchRequest<Message>? {
        let templateName = "fetchMessage"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<Message>
            else {
                print("Error with Template: \(templateName)")
                return nil }
        return fetchRequest
    }
}
