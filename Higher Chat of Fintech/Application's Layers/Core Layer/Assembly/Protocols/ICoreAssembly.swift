//
//  ICoreAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import CoreData

protocol ICoreAssembly {
    var multipeerCommunicator: IMultipeerCommunicator { get }
    var coreDataStack: ICoreDataStack { get }
    var requestSender: IRequestSender { get }
}
