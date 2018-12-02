//
//  ConversationsListModelDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ConversationsListModelDelegate: class {
    func receiveNewMessage(text: String, fromUser: String, toUser: String)
    func sendNewMessage(text: String, fromUser: String, toUser: String)
    func newUser(userID: String, userName: String)
    func lostUser(userID: String)
    func setup(datasource: [ConversationsListCellDisplayModel])
    func show(error message: String)
}
