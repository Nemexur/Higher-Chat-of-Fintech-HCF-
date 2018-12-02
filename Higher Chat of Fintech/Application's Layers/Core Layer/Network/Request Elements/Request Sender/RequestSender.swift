//
//  RequestSender.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 22/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class RequestSender: IRequestSender {
    let session = URLSession.shared
    func send<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> Void) where Parser : IParser {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("Error: 'URL string can not be parsed to URL'"))
            return
        }
        let task = session.dataTask(with: urlRequest) { (data: Data?, _: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error("Error: \(error.localizedDescription)"))
                return
            }
            guard let data = data,
                let parsedModel: Parser.Model = config.parser.parse(data: data) else {
                    completionHandler(Result.error("Error: 'Received Data can not be parsed"))
                    return
            }
            completionHandler(Result.success(parsedModel))
        }
        task.resume()
    }
}
