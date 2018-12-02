//
//  CommunicatorDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/12/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol CommunicatorDelegate: class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}
