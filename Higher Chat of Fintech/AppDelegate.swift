//
//  AppDelegate.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 21.09.2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var State: String = "Not running"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Helper.logIfEnabled("Application moved from '\(State)' to 'Foregroung: \(Helper.stateSetter(UIApplication.shared.applicationState))' \n---\(#function)---")
        State = Helper.stateSetter(UIApplication.shared.applicationState)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Helper.logIfEnabled("Application moved from 'Foreground: \(Helper.stateSetter(UIApplication.shared.applicationState))' to 'Foreground: Inactive' \n---\(#function)---")
        State = "Inactive"
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Helper.logIfEnabled("Application moved from 'Foreground: \(State)' to '\(Helper.stateSetter(UIApplication.shared.applicationState))' \n---\(#function)---")
        State = Helper.stateSetter(UIApplication.shared.applicationState)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Helper.logIfEnabled("Application moved from '\(Helper.stateSetter(UIApplication.shared.applicationState))' to 'Foreground: Inactive' \n---\(#function)---")
        State = "Inactive"
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Helper.logIfEnabled("Application moved from 'Foreground: \(State)' to 'Foreground: \(Helper.stateSetter(UIApplication.shared.applicationState))' \n---\(#function)---")
        State = Helper.stateSetter(UIApplication.shared.applicationState)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Helper.logIfEnabled("Application moved from '\(Helper.stateSetter(UIApplication.shared.applicationState))' to 'Not running' \n---\(#function)---")
        State = "Not running"
    }
    
}
