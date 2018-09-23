//
//  Helper.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class Helper: NSObject {

    class func logIfEnabled(_ string: String) {
        
        let enableLogging: Bool = true
        
        if enableLogging { print(string) }
        
    }
    
    class func stateSetter(_ state: UIApplication.State) -> String {
        
        var statestr: String = ""
        
        switch state {
            
        case .active:
            statestr = "Active"
        case .inactive:
            statestr = "Inactive"
        case .background:
            statestr = "Background"
        default:
            break
            
        }
        
        return statestr
    }
    
}
