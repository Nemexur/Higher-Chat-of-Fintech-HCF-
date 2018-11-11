//
//  CommunicatorProtocol.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 25/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?)
    var delegate: CommunicatorDelegate? { get set }
    var online: Bool { get set }
}

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
