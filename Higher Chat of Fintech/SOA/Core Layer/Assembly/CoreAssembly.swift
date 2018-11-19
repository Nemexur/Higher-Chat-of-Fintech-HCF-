//
//  CoreAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class CoreAssembly: ICoreAssembly {
    lazy var coreDataStack: ICoreDataStack = CoreDataStack()
    lazy var multipeerCommunicator: IMultipeerCommunicator = MultipeerCommunicator(coreDataStack: self.coreDataStack)
}
