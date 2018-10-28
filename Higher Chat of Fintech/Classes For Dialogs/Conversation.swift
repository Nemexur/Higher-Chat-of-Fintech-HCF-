//
//  Conversation.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 06/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

class Conversation {
    var id: String?
    var name: String?
    var messages: [Message]?
    var lastMessage: String?
    var date: Date?
    var online: Bool?
    var hasUnreadMessages: Bool?
    
    
    init(id: String,
         name: String,
         messages: [Message]? = [],
         lastMessage: String?,
         date: Date?,
         online: Bool?,
         hasUnreadMessages: Bool = false) {
        
        self.id = id
        self.name = name
        self.messages = messages
        self.lastMessage = lastMessage
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
    init() { }
    
}
