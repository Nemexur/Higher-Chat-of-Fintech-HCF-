//
//  PresentationAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class PresentationAssembly: IPresentationAssembly {
    private let serviceAssembly: IServiceAssembly
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    func setupConversationsListModel() -> IConversationsListModel {
        return ConversationsListModel(storageManager: serviceAssembly.storageManager, communicatorManager: serviceAssembly.communicationManager, operationManager: serviceAssembly.savingManager)
    }
}
