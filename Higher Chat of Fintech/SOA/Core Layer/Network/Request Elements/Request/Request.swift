//
//  Request.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class Request: IRequest {
    var urlRequest: URLRequest?
    init(urlRequest: URLRequest?) {
        self.urlRequest = urlRequest
    }
}
