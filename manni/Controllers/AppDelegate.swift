//
//  AppDelegate.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import UIKit
import DVB
import SwiftRater
import CoreLocation
import WatchKit
import MapKit
import Material


struct Device {
    static var runningOniPhoneX = false
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        State.shared.loadRouteChanges()
        UIApplication.shared.delegate?.window??.backgroundColor = UIColor.white
        SwiftRater.setUpFor(.distributing)
        
        if #available(iOS 11.0, *) {
            if (window?.safeAreaInsets.top)! > CGFloat(0.0) || window?.safeAreaInsets != .zero {
                Device.runningOniPhoneX = true
            }
            else {
                Device.runningOniPhoneX = false
            }
        }
        
        return true
    }

}

