//
//  User.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

extension User {
    static func insertUser(into context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            return user
        } else {
            return nil
        }
    }

    static func fetchRequestUser(model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let templateName = "fetchUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<User>
            else {
                print("Error with Template: \(templateName)")
                return nil }
        return fetchRequest
    }
}
