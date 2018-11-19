//
//  CommunicationManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 25/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

class CommunicationManager: CommunicatorDelegate, ICommunicationManager {

    weak var delegate: CommunicationManagerDelegate?
    var communicator: IMultipeerCommunicator?
    private let coreAssembly: ICoreAssembly
    var userName: String?

    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        communicator = coreAssembly.multipeerCommunicator
        if communicator?.userName != nil {
            self.userName = communicator?.userName
        } else {
            self.userName = "Русалочка Ариэль"
        }
        communicator?.delegate = self
    }

    // MARK: - Delegate Methods

    func didFoundUser(userID: String, userName: String?) {
        if let user = userName {
            delegate?.newUser(userID: userID, userName: user)
        }
    }

    func didLostUser(userID: String) {
        delegate?.lostUser(userID: userID)
    }

    func failedToStartBrowsingForUsers(error: Error) {
        print(error.localizedDescription)
    }

    func failedToStartAdvertising(error: Error) {
        print(error.localizedDescription)
    }

    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        delegate?.receiveNewMessage(text: text, fromUser: fromUser, toUser: toUser)
    }
}
