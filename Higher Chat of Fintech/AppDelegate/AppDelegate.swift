//
//  AppDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var state: String = "Not running"

    private let profileStoryBoard = UIStoryboard(name: "Profile", bundle: nil)
    private let rootAssembly = RootAssembly()
    private var _rootViewController: ConversationsListViewController?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Get Browser and Advertiser
        advertiser = rootAssembly.getAdvertiser()
        browser = rootAssembly.getBrowser()
        if let rootViewController = profileStoryBoard.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationsListViewController {
            _rootViewController = rootViewController
            rootViewController.conversationsListModel = rootAssembly.presentationAssembly.setupConversationsListModel()
            self.window?.rootViewController = UINavigationController(rootViewController: rootViewController)
            self.window?.makeKeyAndVisible()
        } else {
            print("Unexpected error with ProfileStoryBoard has occurred")
        }

        logIfEnabled("Application moved from '\(state)' to 'Foregroung: \(getStateOfApplication(state: UIApplication.shared.applicationState))' \n---\(#function)---")
        state = getStateOfApplication(state: UIApplication.shared.applicationState)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // To Stop Advertising and Browsing
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        logIfEnabled("Application moved from 'Foreground: \(getStateOfApplication(state: UIApplication.shared.applicationState))' to 'Foreground: Inactive' \n---\(#function)---")
        state = "Inactive"
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Set each Conversation Offline
        _rootViewController?.setOffline()
        logIfEnabled("Application moved from 'Foreground: \(state)' to '\(getStateOfApplication(state: UIApplication.shared.applicationState))' \n---\(#function)---")
        state = getStateOfApplication(state: UIApplication.shared.applicationState)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        logIfEnabled("Application moved from '\(getStateOfApplication(state: UIApplication.shared.applicationState))' to 'Foreground: Inactive' \n---\(#function)---")
        state = "Inactive"
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // To Start Advertising and Browsing
        advertiser?.startAdvertisingPeer()
        browser?.startBrowsingForPeers()
        logIfEnabled("Application moved from 'Foreground: \(state)' to 'Foreground: \(getStateOfApplication(state: UIApplication.shared.applicationState))' \n---\(#function)---")
        state = getStateOfApplication(state: UIApplication.shared.applicationState)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        _rootViewController = nil
        logIfEnabled("Application moved from '\(getStateOfApplication(state: UIApplication.shared.applicationState))' to 'Not running' \n---\(#function)---")
        state = "Not running"
    }

    // MARK: - GetStateOfApplicationFromEnumApplicationState

    func getStateOfApplication(state: UIApplication.State) -> String {

        var stateOfApplication: String = ""

        switch state {

        case .active:
            stateOfApplication = "Active"
        case .inactive:
            stateOfApplication = "Inactive"
        case .background:
            stateOfApplication = "Background"
        default:
            break

        }

        return stateOfApplication
    }
}
