//
//  ImagesModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

struct ImageCellDisplayModel {
    let imageURL: String
    init(imageURL: String) {
        self.imageURL = imageURL
    }
}

class ImagesModel: IImagesModel, NetworkManagerDelegate {
    //Request Configurations
    private let requestConfig = RequestConfigFactory.ImagesRequests.newPixabayConfig()
    private let requestResultType = PixabayJSONModel.self
    weak var delegate: ImagesModelDelegate?
    var networkManager: INetworkManager
    init(networkManager: INetworkManager) {
        self.networkManager = networkManager
        self.networkManager.delegate = self
    }
    func loadImages() {
        if CheckInternet.connection() {
            networkManager.sendRequest(requestResultType, with: requestConfig)
        } else {
            OperationQueue.main.addOperation { self.delegate?.didReceiveError(error: "Error: 'No Internet Connection'") }
        }
    }
    // MARK: - Delegate Functions
    func didReceiveImagesData(result: Codable) {
        var loadedImages: [ImageCellDisplayModel] = []
        //FIXME: If you need to change fetch model, you should change it there as well
        if let receivedModel = result as? PixabayJSONModel {
            for model in receivedModel.hits {
                loadedImages.append(ImageCellDisplayModel(imageURL: model.imageURL))
            }
            OperationQueue.main.addOperation { self.delegate?.didReceiveImages(displayModel: loadedImages) }
        } else {
            OperationQueue.main.addOperation { self.delegate?.didReceiveError(error: "Error: Result Model doesn't conform to SendResult") }
        }
    }
    func didReceiveError(error: String) {
        OperationQueue.main.addOperation { self.delegate?.didReceiveError(error: error) }
    }
}
