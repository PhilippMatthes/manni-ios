//
//  DVB+UIColor.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB

class Gradients {
    public static var all = [
        [UIColor("#56ab2f"), UIColor("#a8e063")],
        [UIColor("#FF416C"), UIColor("#FF4B2B")],
        [UIColor("#fc4a1a"), UIColor("#f7b733")],
        [UIColor("#00c6ff"), UIColor("#0072ff")],
        [UIColor("#396afc"), UIColor("#2948ff")],
        [UIColor("#8E2DE2"), UIColor("#4A00E0")],
        [UIColor("#ec008c"), UIColor("#fc6767")],
    ]
}

extension Departure {
    
    public var gradient: [UIColor] {
        get {
            if let number = Int(line) {
                return Gradients.all[number % Gradients.all.count]
            }
            return Gradients.all[self.line.count % Gradients.all.count]
        }
    }
    
}

extension Stop {
    
    public var gradient: [UIColor] {
        get {
            if let id = Int(self.id) {
                return Gradients.all[abs(id) % Gradients.all.count]
            }
            return Gradients.all[self.name.count % Gradients.all.count]
        }
    }
    
}
