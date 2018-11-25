//
//  RequestsFactory.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

struct APIInformation {
    struct ForPixabayImages {
        static func newPixabayRequest() -> IRequest {
            let numberOfImagesToLoad: Int = 100
            let apiKey: String = "10769411-fa3037b228065780e6ae6782e"
            let urlString = "https://pixabay.com/api/?key=\(apiKey)&q=yellow+flowers&image_type=photo&pretty=true&per_page=\(numberOfImagesToLoad)"
            guard let url = URL(string: urlString) else { return Request(urlRequest: nil) }
            return Request(urlRequest: URLRequest(url: url))
        }
        private init() { }
    }
}
