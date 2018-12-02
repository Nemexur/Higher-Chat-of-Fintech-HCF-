//
//  TinkoffEmblemAnimation.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 29/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

final class TinkoffEmblemView: UIView, IAnimationWithEmitterLayer {
    var rootLayer: CALayer?
    var emitterLayer: CAEmitterLayer?
    var emitterCell: CAEmitterCell?
    private let rootLayerName = "TinkoffEmblemLayer"
    private let emitterLayerName = "TinkoffEmblemEmitterLayer"
    //Image for Emitter Cell
    private let image: UIImage = #imageLiteral(resourceName: "TinkoffEmblem")
    var recognizer: UILongPressGestureRecognizer?
    var view: UIView?
    //To Start Animating Emitter
    func performAnimation() {
        setAllDependenciesAndAttributes()
    }
    //To Stop Animating Emitter
    func stopAnimation() {
        guard let sublayers = view?.layer.sublayers else { return }
        for layer in sublayers where layer.name == rootLayerName {
            layer.removeFromSuperlayer()
        }
    }
    //To Change Position of Animation
    func changeAnimationPosition() {
        guard let layer = view?.layer.sublayers?.first(where: {$0.name == rootLayerName}),
            let emitterLayer = layer.sublayers?.first(where: {$0.name == emitterLayerName }),
            let emitter = emitterLayer as? CAEmitterLayer,
            let position = recognizer?.location(in: view)
        else { return }
        emitter.emitterPosition = position
    }
    //Setup All Requeired Elements of Animation
    private func setAllDependenciesAndAttributes() {
        setupRootLayer()
        setupEmitterLayer()
        setupEmitterCell()
        guard let existingEmitterCell = emitterCell else { return }
        emitterLayer?.emitterCells = [existingEmitterCell]
        guard let existingEmitterLayer = emitterLayer else { return }
        rootLayer?.addSublayer(existingEmitterLayer)
        guard let existingRootLayer = rootLayer else { return }
        view?.layer.addSublayer(existingRootLayer)
    }
    private func setupRootLayer() {
        rootLayer?.backgroundColor = UIColor(white: 1, alpha: 0.6).cgColor
        rootLayer?.name = rootLayerName
    }
    private func setupEmitterLayer() {
        emitterLayer?.emitterSize = bounds.size
        emitterLayer?.emitterShape = .rectangle
        guard let position = recognizer?.location(in: view) else { return }
        emitterLayer?.emitterPosition = position
        emitterLayer?.name = emitterLayerName
    }
    private func setupEmitterCell() {
        emitterCell?.color = UIColor(white: 1, alpha: 0.5).cgColor
        emitterCell?.contents = image.cgImage
        emitterCell?.lifetime = 1.5
        emitterCell?.birthRate = 6
        emitterCell?.alphaRange = 0.4
        emitterCell?.velocity = 90
        emitterCell?.scale = 0.4
        emitterCell?.spin = CGFloat(360).degreesToRadians
        emitterCell?.scaleRange = 0.8
        emitterCell?.emissionRange = CGFloat.pi * 2
        emitterCell?.emissionLongitude = CGFloat.pi * 4
        emitterCell?.yAcceleration = -350
        emitterCell?.scaleSpeed = -0.1
        emitterCell?.alphaSpeed = -0.7
        emitterCell?.scaleRange = 0.1
        emitterCell?.beginTime = 0.2
    }
}
