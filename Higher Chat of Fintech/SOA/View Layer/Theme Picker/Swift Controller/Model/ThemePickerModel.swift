//
//  ThemePickerModel.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 18/11/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation

class ThemePickerModel: IThemePickerModel {
    func getThemes() -> [String: UIColor] {
        return [
            "Theme1": UIColor.red,
            "Theme2": UIColor.yellow,
            "Theme3": UIColor.green,
            "DefaultTheme": UIColor.white
        ]
    }
}
