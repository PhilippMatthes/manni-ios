//
//  LaterCell.swift
//  manni
//
//  Created by Philipp Matthes on 06.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Motion
import Material

class LaterCell: TableViewCell {
    
    static let identifier = "laterCell"
    static let height: CGFloat = 75.0
    
    func configure() {
        self.textLabel?.text = Config.laterButtonText
        self.textLabel?.textColor = .white
        
        let color: UIColor = Color.grey.base
        self.backgroundColor = color
        self.pulseColor = color.lighter()!
        
        self.imageView?.image = Icon.cm.search
        self.imageView?.tintColor = UIColor.white
    }
    
}
