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
    
    static let height: CGFloat = 50
    
    func setUp(forStop stop: Stop) {
        if let region = stop.region {
            self.textLabel?.text = "\(stop.name) (\(region))"
        } else {
            self.textLabel?.text = "\(stop.name)"
        }
        self.textLabel?.textColor = UIColor.white
        
        let color: UIColor = Colors.color(forInt: stop.name.count)
        self.backgroundColor = color
        self.pulseColor = color.lighter()!
        
        self.imageView?.image = Icon.cm.menu
        self.imageView?.tintColor = UIColor.white
    }
    
    func setUp(forStopName stopName: String) {
        self.textLabel?.text = "\(stopName)"
        
        self.textLabel?.textColor = UIColor.white
        
        let color: UIColor = Colors.color(forInt: stopName.count)
        self.backgroundColor = color
        self.pulseColor = color.lighter()!
        
        self.imageView?.image = Icon.cm.menu
        self.imageView?.tintColor = UIColor.white
    }
    
}

