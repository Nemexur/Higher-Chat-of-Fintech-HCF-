//
//  IConversationDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ConversationModelDelegate: class {
    func receiveNewMessage(text: String, fromUser: String, toUser: String)
    func sendNewMessage(text: String, fromUser: String, toUser: String)
    func newUser(userID: String, userName: String)
    func lostUser(userID: String)
    func setup(datasource: [ConversationCellDisplayModel])
    func show(error message: String)
}
