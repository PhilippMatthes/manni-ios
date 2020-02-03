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
        UIColor("#4b7bec"),
        UIColor("#26de81"),
        UIColor("#45aaf2"),
        UIColor("#a55eea"),
        UIColor("#eb3b5a"),
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
            return Colors.all[abs(self.id.hashValue) % Colors.all.count]
        }
    }
    
}
