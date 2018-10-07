//
//  Message.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 06/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

public class Message {
    var text: String?
    var isIncoming: Bool?
    
    
    init(text: String?, isIncoming: Bool) {
        self.text = text
        self.isIncoming = isIncoming
    }
    
    
    init() { }
    
}
