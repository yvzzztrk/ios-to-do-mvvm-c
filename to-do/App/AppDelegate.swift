//
//  AppDelegate.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Application.shared.start(in: window)
        return true
    }

}

