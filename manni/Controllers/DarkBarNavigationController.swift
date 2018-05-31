//
//  DarkBarNavigationController.swift
//  manni
//
//  Created by Philipp Matthes on 27.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Motion

class DarkBarNavigationController: NavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return Device.runningOniPhoneX
    }
}
