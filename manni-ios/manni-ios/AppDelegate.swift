//
//  AppDelegate.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import UIKit
import Material

protocol ViewTapDelegate {
    func viewWasTapped()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    
    public static var viewTapDelegate: ViewTapDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: Screen.bounds)
        let rootViewController = SearchController()
        window!.rootViewController = rootViewController
        window!.makeKeyAndVisible()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        window!.addGestureRecognizer(tapGesture)
        
        return true
    }

}

extension AppDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        AppDelegate.viewTapDelegate?.viewWasTapped()
        return false
    }
}

