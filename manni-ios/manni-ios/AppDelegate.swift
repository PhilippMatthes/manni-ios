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
        
        if #available(iOS 11.0, *) {
            if let topInset = window?.safeAreaInsets.top, topInset > 0 {
                // iPhone X
                let frame = CGRect(x: 0, y: 0, width: Screen.width, height: topInset)
                let nodgeView = UIView()
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor.black.withAlphaComponent(0.5).cgColor,
                    UIColor.clear.cgColor
                ]
                gradientLayer.startPoint = .init(x: 0, y: 0)
                gradientLayer.endPoint = .init(x: 0, y: 1)
                gradientLayer.frame = frame
                nodgeView.layer.addSublayer(gradientLayer)
                nodgeView.frame = frame
                window!.addSubview(nodgeView)
            }
        }
        
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

