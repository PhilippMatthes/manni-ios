//
//  DetailRowController.swift
//  manni-watch Extension
//
//  Created by Philipp Matthes on 20.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit

class DepartureRowController: NSObject {
    
    @IBOutlet weak var lineLabelBackground: WKInterfaceGroup!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var lineLabel: WKInterfaceLabel!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var label: WKInterfaceLabel!
    
    func configure(time: Date, line: String, direction: String) {
        lineLabel.setText(line)
        label.setText(direction)
        timer.setDate(time)
        timer.start()
    }
}
