//
//  ServiceAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class ServiceAssembly: IServiceAssembly {
    private let coreAssembly: ICoreAssembly
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
    }
    lazy var storageManager: IStorageManager = StorageManager(coreAssembly: self.coreAssembly)
    lazy var savingManager: ISavingData = OperationDataManager()
    lazy var communicationManager: ICommunicationManager = CommunicationManager(coreAssembly: self.coreAssembly)
    lazy var networkManager: INetworkManager = NetworkManager(coreAssembly: self.coreAssembly)
}
