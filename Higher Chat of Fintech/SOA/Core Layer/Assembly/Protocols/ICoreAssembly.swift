//
//  ICoreAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ICoreAssembly {
    var multipeerCommunicator: IMultipeerCommunicator { get set }
    var coreDataStack: ICoreDataStack { get set }
    var requestSender: IRequestSender { get set }
}
