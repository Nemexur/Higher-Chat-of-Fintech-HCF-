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
    var name: String?
    var messages: [Message]?
    var lastMessage: String?
    var date: Date?
    var online: Bool?
    var hasUnreadMessages: Bool?
    
    
    init(name: String,
         messages: [Message] = [],
         lastMessage: String?,
         date: String,
         online: Bool,
         hasUnreadMessages: Bool = false) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let newdate = formatter.date(from: date)
        
        self.name = name
        self.messages = messages
        self.lastMessage = lastMessage
        self.date = newdate
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
    init() { }
    
}
