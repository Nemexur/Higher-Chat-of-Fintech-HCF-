//
//  GenerateMessageID.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 25/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

public func generateMessageID() -> String {
    return "\(arc4random_uniform(UINT32_MAX)) + \(Date.timeIntervalSinceReferenceDate) + \(arc4random_uniform(UINT32_MAX))".data(using: .utf8)!.base64EncodedString()
}
