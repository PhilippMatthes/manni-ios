//
//  DVB+UIColor.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB

extension Departure {
    
    public var gradient: [UIColor] {
        get {
            if let number = Int(line) {
                return Gradients.accentColors[number % Gradients.accentColors.count]
            }
            return Gradients.accentColors[self.line.count % Gradients.accentColors.count]
        }
    }
    
}

extension Stop {
    
    public var gradient: [UIColor] {
        get {
            if let id = Int(self.id) {
                return Gradients.accentColors[abs(id) % Gradients.accentColors.count]
            }
            return Gradients.accentColors[self.name.count % Gradients.accentColors.count]
        }
    }
    
}
