//
//  ImageLoaderDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 01/12/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol ImageLoaderDelegate: class {
    func didSetImage(image: UIImage)
    func didReceiveError(error: String)
    func startIndicator()
    func stopIndicator()
}
