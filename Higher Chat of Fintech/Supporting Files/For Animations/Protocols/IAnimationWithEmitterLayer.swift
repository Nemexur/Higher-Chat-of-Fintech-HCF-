//
//  IAnimationWithEmitterLayer.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 29/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol IAnimationWithEmitterLayer {
    var rootLayer: CALayer? { get set }
    var emitterLayer: CAEmitterLayer? { get set }
    var emitterCell: CAEmitterCell? { get set }
    var recognizer: UILongPressGestureRecognizer? { get set }
    var view: UIView? { get set }
    func performAnimation()
    func stopAnimation()
    func changeAnimationPosition()
}
