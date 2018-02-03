//
//  ColorGenerator.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class Colors {
    
    static let colors: [UIColor] = [
        UIColor(rgb: 0xf44336, alpha: 1.0),
        UIColor(rgb: 0xe91e63, alpha: 1.0),
        UIColor(rgb: 0x9c27b0, alpha: 1.0),
        UIColor(rgb: 0x673ab7, alpha: 1.0),
        UIColor(rgb: 0x3f51b5, alpha: 1.0),
        UIColor(rgb: 0x2196f3, alpha: 1.0),
        UIColor(rgb: 0x03a9f4, alpha: 1.0),
        UIColor(rgb: 0x00bcd4, alpha: 1.0),
        UIColor(rgb: 0x009688, alpha: 1.0),
        UIColor(rgb: 0x4caf50, alpha: 1.0),
        UIColor(rgb: 0x8bc34a, alpha: 1.0),
        UIColor(rgb: 0xffc107, alpha: 1.0),
    ]
    
    static func color(forInt line: Int) -> UIColor {
        return Colors.colors[line.mod(Colors.colors.count)]
    }
    
    static func standardColor() -> UIColor {
        return Colors.colors.first!
    }
    
}
