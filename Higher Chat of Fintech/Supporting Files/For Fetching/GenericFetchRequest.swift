//
//  GenericFetchRequest.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 19/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

func getFetchRequestData<T: NSManagedObject>(_ entityType: T.Type, dataManager: IStorageManager, predicate: NSPredicate? = nil) -> [T] {
    guard let context = dataManager.coreDataContextToSaveNewData else { return [] }
    if let request: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> {
        if predicate != nil {
            request.predicate = predicate
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Error in fetching Data")
            return []
        }
    } else {
        return []
    }
}
