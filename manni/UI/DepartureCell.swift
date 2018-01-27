//
//  DepartureCell.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Motion
import UIKit
import DVB

class DepartureCell: TableViewCell {
    
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: RaisedButton!

    
    func setUp(forDeparture departure: Departure) {
        
        let direction = departure.direction
        let eta = departure.ETA
        let delay = departure.ETA - departure.scheduledETA
        let line = departure.line
        
        var platformName: String
        if let platform = departure.platform {
            platformName = platform.name
        } else {
            platformName = "n/a"
        }

        var time: String
        if let departureTime = departure.realTime {
            time = departureTime.time()
        } else {
            time = "n/a"
        }
        
        var changesString = ""
        if let routeChangeIDs = departure.routeChanges {
            let routeChanges = State.shared.routeChanges(forChangeIDs: routeChangeIDs)
            for change in routeChanges {
                changesString += change
            }
        }
        
        self.titleLabel1.text = "\(direction)"
        if delay == 0 {
            self.titleLabel2.text = "In \(eta) min"
        } else if delay > 0 {
            self.titleLabel2.text = "In \(eta) min (\(delay) min Verspätung)"
        } else {
            self.titleLabel2.text = "In \(eta) min (\(-delay) min zu früh)"
        }
        self.detailLabel.text = "\(changesString) Fahrt von Bahnsteig \(platformName)"
        self.timeLabel.text = "Vsl. Abfahrt: \(time)"
        self.button.setTitle("\(line)", for: .normal)
        
        self.titleLabel1.textColor = UIColor.white
        self.titleLabel2.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
        self.timeLabel.textColor = UIColor.white
        self.button.titleLabel?.textColor = UIColor.white
        
        var color = Colors.standardColor()
        if let lineNumber = Int(departure.line) {
            color = Colors.color(forInt: lineNumber)
        }
        
        self.backgroundColor = color
        self.button.backgroundColor = color.lighter(by: 15)!
        self.pulseColor = color.lighter()!
        self.button.shadowColor = color.darker()!
    }
    
}
