//
//  ICommunicationManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ICommunicationManager {
    var delegate: CommunicationManagerDelegate? { get set }
    var communicator: IMultipeerCommunicator? { get set }
    var userName: String? { get set }
}
