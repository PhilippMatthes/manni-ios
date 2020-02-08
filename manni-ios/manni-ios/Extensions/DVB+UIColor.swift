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
        UIColor("#2191FB"),
        UIColor("#2364AA"),
        UIColor("#33658A"),
        UIColor("#86BBD8"),
        UIColor("#2F4858"),
        UIColor("#01295F"),
        UIColor("#2364AA"),
        UIColor("#054A91"),
        UIColor("#3E7CB1"),
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
