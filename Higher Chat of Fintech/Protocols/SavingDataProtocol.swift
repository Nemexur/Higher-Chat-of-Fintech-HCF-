//
//  SavingDataProtocol.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

protocol SavingDataProtocol {
    var errorFunction: (() -> ())? { get set }
    var completion: (() -> ())? { get set }
    var buttonsAndIndicatorAppearance: (() -> ())? { get set }
    
    func saveData()
    func getUserDataFromFileManager() -> (profileNameText: String?, profileDescriptionText: String?, profileImage: UIImage?)
}
