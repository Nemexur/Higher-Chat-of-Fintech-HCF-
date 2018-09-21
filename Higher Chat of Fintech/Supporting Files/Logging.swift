//
//  Logging.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class Logging: NSObject {
    
    private let enableLogging: Bool = true
    
    class var instance: Logging  {
        struct Singleton {
            static let instance = Logging()
        }
        return Singleton.instance
    }
    
    internal func logIfEnabled(_ string: String) {
//        #if DEBUG
//        print(string)
//        #endif
        if enableLogging { print(string) }
        
    }
    
}
