//
//  INetworkManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol INetworkManager: class {
    var requestSender: IRequestSender { get set }
    var delegate: NetworkManagerDelegate? { get set }
    func sendRequest<Parser, SendResult: Codable>(_ type: SendResult.Type, with config: RequestConfig<Parser>)
}
