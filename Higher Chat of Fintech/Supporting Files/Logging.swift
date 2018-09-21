//
//  Logging.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class Logging: NSObject {

    class func logIfEnabled(_ string: String) {
        #if DEBUG
        print(string)
        #endif
    }
    
}
