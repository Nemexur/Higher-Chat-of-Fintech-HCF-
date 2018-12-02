//
//  NetworkManagerDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 24/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol NetworkManagerDelegate: class {
    func didReceiveImagesData(result: Codable)
    func didReceiveError(error: String)
}
