//
//  SwiftRaterExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 21.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import SwiftRater

enum SwiftRaterMode {
    case testing
    case distributing
}

extension SwiftRater {
    
    static func setUpFor(_ mode: SwiftRaterMode) {
        switch mode {
        case .testing:
            SwiftRater.debugMode = true
        case .distributing:
            SwiftRater.debugMode = false
        }
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.appLaunched()
    }
    
}

