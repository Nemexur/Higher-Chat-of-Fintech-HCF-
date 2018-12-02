//
//  ParserForPixabay.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class ParserForPixabay: IParser {
    typealias Model = PixabayJSONModel
    func parse(data: Data) -> PixabayJSONModel? {
        let jsonDecoder = JSONDecoder()
        do {
            let pixabayModel = try jsonDecoder.decode(PixabayJSONModel.self, from: data)
            return pixabayModel
        } catch {
            return nil
        }
    }
}
