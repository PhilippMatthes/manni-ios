//
//  DVB+UIColor.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB
import UIKit

// TODO: Refactor duplicated code

extension Departure {
    
    public var gradient: [UIColor] {
        get {
            if let number = Int(line) {
                return Gradients.accentColors[abs(number) % Gradients.accentColors.count]
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

extension Route.ModeElement {
    
    public var gradient: [UIColor] {
        get {
            guard let name = name else {return Gradients.accentColors.first!}
            if let number = Int(name) {
                return Gradients.accentColors[abs(number) % Gradients.accentColors.count]
            }
            return Gradients.accentColors[name.count % Gradients.accentColors.count]
        }
    }
    
}
