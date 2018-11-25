//
//  ImagesModelDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ImagesModelDelegate: class {
    func didReceiveImages(displayModel: [ImageCellDisplayModel])
    func didReceiveError(error: String)
}
