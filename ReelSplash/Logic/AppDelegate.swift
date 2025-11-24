//
//  AppDelegate.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/19/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        OrientationManager.shared.orientationMask
    }
}
