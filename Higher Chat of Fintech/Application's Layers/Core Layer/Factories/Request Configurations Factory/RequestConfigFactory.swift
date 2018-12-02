//
//  RequestFactory.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

struct RequestConfigFactory {
    struct ImagesRequests {
        static func newPixabayConfig() -> RequestConfig<ParserForPixabay> {
            return RequestConfig<ParserForPixabay>(request: APIInformation.ForPixabayImages.newPixabayRequest(), parser: ParserForPixabay())
        }
    }
}
