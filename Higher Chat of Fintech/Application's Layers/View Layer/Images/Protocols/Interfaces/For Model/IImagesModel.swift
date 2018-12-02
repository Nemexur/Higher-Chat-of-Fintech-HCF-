//
//  IImagesModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol IImagesModel: class {
    var delegate: ImagesModelDelegate? { get set }
    var networkManager: INetworkManager { get }
    func loadImages()
}
