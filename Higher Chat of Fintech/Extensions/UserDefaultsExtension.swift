//
//  UserDefaultsExtension.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {

    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            do {
                color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
            } catch {
                print(error.localizedDescription)
                color = nil
            }
        }
        return color
    }

    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            do {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true) as NSData
            } catch {
                print(error.localizedDescription)
                colorData = nil
            }
        }
        set(colorData, forKey: key)
    }

}
