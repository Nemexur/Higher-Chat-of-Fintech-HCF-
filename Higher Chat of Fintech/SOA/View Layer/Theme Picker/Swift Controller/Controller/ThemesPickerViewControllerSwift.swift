//
//  ThemesPickerViewControllerSwift.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 12/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ThemesPickerViewControllerSwift: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var topBarTheme: UIView!

    // MARK: - Themes Class

    private var themes: Themes = Themes()

    // MARK: - Delegate

    var onThemesViewControllerDelegate: ((_ didSelectTheme: UIColor) -> Void)?

    // MARK: - Dictionary for colors

    private var colorsForThemes: [String: UIColor] = [:]
    var themesPickerModel: IThemePickerModel?

    // MARK: - Overrided UIViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTopBarThemeView()
        gettingThemes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        themes.setThemes(colorsForThemes["DefaultTheme"] ?? UIColor.white,
                         setTheme1: colorsForThemes["Theme1"] ?? UIColor.white,
                         setTheme2: colorsForThemes["Theme2"] ?? UIColor.white,
                         setTheme3: colorsForThemes["Theme3"] ?? UIColor.white)
    }

    // MARK: - Additional Functions

    private func gettingThemes() {
        if let themesColors = themesPickerModel?.getThemes() {
            colorsForThemes = themesColors
        }
    }
    private func configureTopBarThemeView() {
        topBarTheme.layer.cornerRadius = 10
        topBarTheme.layer.borderColor = UIColor.black.cgColor
        topBarTheme.layer.borderWidth = 1
    }

    private func setDelegateThemes(theme: UIColor) {
        self.view.backgroundColor = theme
        onThemesViewControllerDelegate?(theme)
    }

    // MARK: - Button Actions

    @IBAction func pickTheme1(_ sender: Any) {
        setDelegateThemes(theme: themes.theme1)
    }

    @IBAction func pickTheme2(_ sender: Any) {
        setDelegateThemes(theme: themes.theme2)
    }

    @IBAction func pickTheme3(_ sender: Any) {
        setDelegateThemes(theme: themes.theme3)
    }

    @IBAction func pickDefaultTheme(_ sender: Any) {
        setDelegateThemes(theme: themes.defaultTheme)
    }

}
