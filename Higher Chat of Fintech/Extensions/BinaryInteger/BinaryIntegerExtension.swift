//
//  FloatingPointExtension.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 30/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}
