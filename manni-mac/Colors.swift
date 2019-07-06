//
//  Colors.swift
//  manni-mac
//
//  Created by Philipp Matthes on 21.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {
    convenience init(rgb: Int, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF)/255,
            green: CGFloat((rgb >> 8) & 0xFF)/255,
            blue: CGFloat(rgb & 0xFF)/255,
            alpha: alpha
        )
    }
    
    static let colors: [NSColor] = [
        NSColor(rgb: 0xf44336, alpha: 1.0),
        NSColor(rgb: 0xe91e63, alpha: 1.0),
        NSColor(rgb: 0x9c27b0, alpha: 1.0),
        NSColor(rgb: 0x673ab7, alpha: 1.0),
        NSColor(rgb: 0x3f51b5, alpha: 1.0),
        NSColor(rgb: 0x2196f3, alpha: 1.0),
        NSColor(rgb: 0x03a9f4, alpha: 1.0),
        NSColor(rgb: 0x00bcd4, alpha: 1.0),
        NSColor(rgb: 0x009688, alpha: 1.0),
        NSColor(rgb: 0x4caf50, alpha: 1.0),
        NSColor(rgb: 0x8bc34a, alpha: 1.0),
        NSColor(rgb: 0xffc107, alpha: 1.0),
    ]
    
    static func color(forInt line: Int?) -> NSColor {
        return line == nil ? colors.first! : colors[line!.mod(colors.count)]
    }
    
    static func standardColor() -> NSColor {
        return colors.first!
    }
}

