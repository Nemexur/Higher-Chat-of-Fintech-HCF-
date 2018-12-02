//
//  IImageLoader.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/12/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol IImageLoader {
    var imageURL: String? { get set }
    var delegate: ImageLoaderDelegate? { get set }
    func setImageWithImageURL()
}
