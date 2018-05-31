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
    
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var label: WKInterfaceLabel!
    
    var timer: Timer?
    var time: Date!
    var line: String!
    var direction: String!
    
    func setDepartureTime(time: Date, line: String, direction: String) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
        self.time = time
        self.line = line
        self.direction = direction
        update()
    }
    
    @objc func update() {
        let currentTime = Date()
        let minutes = time.minutes(from: currentTime)
        let seconds = minutes < 5 && minutes > -5 ? time.seconds(from: currentTime) % 60 : 0
        label.setText(seconds == 0 ? "\(line!) \(direction!) in \(minutes) min" : "\(line!) \(direction!) in \(minutes) min, \(seconds) s")
    }
}
