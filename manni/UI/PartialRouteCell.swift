//
//  RouteDetailCell.swift
//  manni
//
//  Created by Philipp Matthes on 03.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material
import Motion

class PartialRouteCell: TableViewCell {
    static let identifier = "partialRouteCell"
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromDetailLabel: UILabel!
    @IBOutlet weak var lineChangesLabel: UILabel!
    @IBOutlet weak var lineButton: RaisedButton!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toDetailLabel: UILabel!
    @IBOutlet weak var visualBar: UIView!
    
    func configure(forPartialRoute partialRoute: Route.RoutePartial) {
        
        var color: UIColor
        if let lineName = partialRoute.mode.name {
            if let lineID = Int(lineName) {
                color = Colors.color(forInt: lineID)
            } else {
                color = Colors.color(forInt: lineName.count)
            }
        } else {
            color = Colors.color(forInt: partialRoute.mapDataIndex)
        }
        
        backgroundColor = color
        pulseColor = color.lighter()!
        lineButton.backgroundColor = color.lighter(by: 15)!
        lineButton.shadowColor = color.darker()!
        visualBar.layer.cornerRadius = visualBar.frame.width / 2
        
        lineButton.layer.borderWidth = 3.0
        lineButton.layer.borderColor = UIColor.white.cgColor
        
        if let stops = partialRoute.regularStops {
            fromLabel.text = stops.first?.name
            fromDetailLabel.text = "\(stops.first!.departureTime.time())"
            toLabel.text = stops.last?.name
            toDetailLabel.text = stops.last?.arrivalTime.time()
        }
        var description: String = ""
        if let direction = partialRoute.mode.direction {
            description += "Richtung \(direction)"
        }
        if let duration = partialRoute.duration {
            description += description == "" ? "Dauer: \(duration) min" : ", Dauer: \(duration) min"
        }
        if let routeChangeIDs = partialRoute.mode.changes {
            description += description == "" ? "Änderungen: \(State.shared.routeChanges(forChangeIDs: routeChangeIDs))" : ", Änderungen: \(State.shared.routeChanges(forChangeIDs: routeChangeIDs))"
        }
        lineChangesLabel.text = description
        
        lineButton.setTitle(partialRoute.mode.name, for: .normal)
    }
}
