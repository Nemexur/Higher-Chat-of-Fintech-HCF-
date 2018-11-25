//
//  NetworkManager.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class NetworkManager: INetworkManager {
    weak var delegate: NetworkManagerDelegate?
    var requestSender: IRequestSender
    private let coreAssembly: ICoreAssembly
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        self.requestSender = self.coreAssembly.requestSender
    }
    func sendRequest<Parser, SendResult: Codable>(_ type: SendResult.Type, with config: RequestConfig<Parser>) {
        requestSender.send(config: config) { (result: Result<Parser.Model> ) in
            switch result {
            case .success(let receivedModel):
                if let model = receivedModel as? SendResult {
                    self.delegate?.didReceiveImagesData(result: model)
                } else {
                    self.delegate?.didReceiveError(error: "Error: Result Model doesn't conform to SendResult")
                }
            case .error(let error):
                self.delegate?.didReceiveError(error: error)
            }
        }
    }
}
