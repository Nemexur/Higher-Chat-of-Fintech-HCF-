//
//  IServiceAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol IServiceAssembly {
    var storageManager: IStorageManager { get }
    var savingManager: ISavingData { get }
    var communicationManager: ICommunicationManager { get }
}
