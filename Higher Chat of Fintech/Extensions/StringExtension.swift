//
//  StringExtension.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var withoutSpecialCharacters: String? {
        let availableCharacters = Set("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя ABCDEFGHIJKLKMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ1234567890+-=().!_")
        return self.filter { availableCharacters.contains($0) }
    }
}
