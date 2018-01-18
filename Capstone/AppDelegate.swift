//
//  AppDelegate.swift
//  Capstone
//
//  Created by Aidan Madden on 11/20/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let redirectURL: URL = URL(string:"capstonelogin://callback")!
        SpotifyLogin.shared.configure(clientID: "58c49f01f0c2403abac1de918f4223c0", clientSecret: "ff7ada93f5124ff8bd8386eb3d12dc4d", redirectURL: redirectURL)
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { (error) in }
        return handled
    }

}

