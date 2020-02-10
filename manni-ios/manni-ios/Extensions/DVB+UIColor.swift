//
//  DVB+UIColor.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB

class Colors {
    public static var all = [
        UIColor("#3742fa"),
        UIColor("#ff4757"),
        UIColor("#ff6348"),
        UIColor("#ffa502"),
        UIColor("#2ed573"),
        UIColor("#1e90ff"),
        UIColor("#747d8c"),
        UIColor("#2f3542"),
        UIColor("#57606f"),
    ]
}

extension Departure {
    
    public var color: UIColor {
        get {
            if let number = Int(line) {
                return Colors.all[number % Colors.all.count]
            }
            return Colors.all[self.line.count % Colors.all.count]
        }
    }
    
}

extension Stop {
    
    public var color: UIColor {
        get {
            if let id = Int(self.id) {
                return Colors.all[abs(id) % Colors.all.count]
            }
            return Colors.all[self.name.count % Colors.all.count]
        }
    }
    
}
