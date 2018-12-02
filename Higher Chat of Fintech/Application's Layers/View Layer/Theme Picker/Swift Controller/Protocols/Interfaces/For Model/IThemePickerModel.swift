//
//  IThemePickerModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

protocol IThemePickerModel: class {
    func getThemes() -> [String: UIColor]
}
