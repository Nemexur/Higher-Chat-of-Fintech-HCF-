//
//  FloatingPointExtension.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 30/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
