//
//  RootAssembly.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 17/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class RootAssembly {
    private lazy var coreAssembly: ICoreAssembly = CoreAssembly()
    private lazy var serviceAssembly: IServiceAssembly = ServiceAssembly(coreAssembly: self.coreAssembly)
    lazy var presentationAssembly: IPresentationAssembly = PresentationAssembly(serviceAssembly: self.serviceAssembly)
    //Get Advertiser
    func getAdvertiser() -> MCNearbyServiceAdvertiser {
        return coreAssembly.multipeerCommunicator.advertiser
    }
    //Get Browser
    func getBrowser() -> MCNearbyServiceBrowser {
        return coreAssembly.multipeerCommunicator.browser
    }
}
