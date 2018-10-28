//
//  CommunicationManagerDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 25/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

protocol CommunicationManagerDelegate: class {
    func receiveNewMessage(text: String, fromUser: String, toUser: String)
    func sendNewMessage(text: String, fromUser: String, toUser: String)
    func newUser(userID: String, userName: String)
    func lostUser(userID: String)
}
