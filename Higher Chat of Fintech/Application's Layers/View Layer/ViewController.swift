//
//  ViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        super.loadView()
        logIfEnabled("\nViewController moved from 'Initialize' to 'Loading' \n---\(#function)---")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logIfEnabled("ViewController moved from 'Loading' to 'Loaded' \n---\(#function)---")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        logIfEnabled("ViewController moved from 'Loaded' to 'About to appear' \n---\(#function)---")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        logIfEnabled("ViewController moved from 'Laid subviews' to 'Appeared' \n---\(#function)---\n")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        logIfEnabled("ViewController moved from 'Appeared' to 'About to disappear' \n---\(#function)---")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        logIfEnabled("ViewController moved from 'About to disappear' to 'Disappeared' \n---\(#function)---")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logIfEnabled("ViewController moved from 'About to appear' to 'About to lay subviews' \n---\(#function)---")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logIfEnabled("ViewController moved from 'About to lay subviews' to 'Laid subviews' \n---\(#function)---")
    }

}
