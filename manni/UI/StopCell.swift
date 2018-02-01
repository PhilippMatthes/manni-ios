//
//  StopCell.swift
//  manni
//
//  Created by Philipp Matthes on 01.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material
import Motion

class StopCell: TableViewCell {
    
    static let identifier = "stopCell"
    
    func setUp(forStop stop: Stop) {
        if let region = stop.region {
            self.textLabel?.text = "\(stop.name) (\(region))"
        } else {
            self.textLabel?.text = "\(stop.name)"
        }
        
        self.textLabel?.textColor = UIColor.white
        
        var color: UIColor
        if let lineNumber = Int(stop.id) {
            color = Colors.color(forInt: lineNumber)
        } else {
            color = Colors.color(forInt: stop.description.count)
        }
        self.backgroundColor = color
        self.pulseColor = color.lighter()!
        
        self.imageView?.image = Icon.cm.menu
        self.imageView?.tintColor = UIColor.white
    }
    
}

