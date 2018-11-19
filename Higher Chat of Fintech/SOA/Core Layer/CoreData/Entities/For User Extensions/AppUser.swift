//
//  AppUser.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

extension AppUser {
    static func insertAppUser(into context: NSManagedObjectContext) -> AppUser? {
        var appUserToFetch: AppUser?
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.insertUser(into: context)
                appUser.currentUser = currentUser
            }
            appUserToFetch = appUser
        } else {
            appUserToFetch = nil
        }
        return appUserToFetch
    }

    static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "fetchAppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser>
            else {
                print("Error with Template: \(templateName)")
                return nil }
        return fetchRequest
    }
}
