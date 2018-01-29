//
//  AppDelegate.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import UIKit
import DVB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        State.shared.loadRouteChanges()
        
//        Locator.allstops(forLineName: "12 Leutewitz", startPointName: "Leutewitz", endPointName: "Tharandter Straße") {
//            (routeStops) in
//            if let routeStops = routeStops {
//                Locator.alloccurences(forLineName: "12", direction: "Leutewitz", routeStops: routeStops) {_,_ in}
//            }
//        }
        
        
        window!.rootViewController = ModularSearchBarController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootSearchBarController"))
        window!.makeKeyAndVisible()
        return true
    }


}

