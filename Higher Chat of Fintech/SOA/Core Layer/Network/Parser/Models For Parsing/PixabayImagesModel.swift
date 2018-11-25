//
//  PixabayImagesModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

struct PixabayImagesModel: Codable {
    let imageURL: String
    let tags: String
    let user: String
    enum CodingKeys: String, CodingKey {
        case imageURL = "largeImageURL"
        case tags = "tags"
        case user = "user"
    }
}

struct PixabayJSONModel: Codable {
    let totalHits: Int
    let hits: [PixabayImagesModel]
    let total: Int
}
