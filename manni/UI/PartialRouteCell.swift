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
    
    @IBOutlet weak var lineButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromDetailLabel: UILabel!
    @IBOutlet weak var lineChangesLabel: UILabel!
    @IBOutlet weak var lineButton: RaisedButton!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toDetailLabel: UILabel!
    @IBOutlet weak var visualBar: UIView!
    var pointView: UIView?
    var timer: Timer?
    var partialRoute: Route.RoutePartial!
    
    func configure(forPartialRoute partialRoute: Route.RoutePartial) {
        self.partialRoute = partialRoute
        
        updatePoint()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updatePoint), userInfo: nil, repeats: true)
        
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
        
        let direction = partialRoute.mode.direction == nil ? nil : "Richtung \(partialRoute.mode.direction!)"
        let duration = partialRoute.duration == nil ? nil : "Dauer: \(partialRoute.duration!) min"
        let routeChanges = partialRoute.mode.changes == nil ? nil : "Änderungen: \(State.shared.routeChanges(forChangeIDs: partialRoute.mode.changes!).joined(separator: ", "))"
        lineChangesLabel.text = [direction, duration, routeChanges].flatMap{$0}.joined(separator: ", ")
        
        lineButton.setTitle(partialRoute.mode.name, for: .normal)
        let customButtonFrameWidth = partialRoute.mode.name == nil ? nil : min(70, max(50, CGFloat(partialRoute.mode.name!.count)*10))
        if customButtonFrameWidth != nil {
            lineButtonWidthConstraint.constant = customButtonFrameWidth!
            contentView.layoutSubviews()
        }
    }
    
    @objc func updatePoint() {
        if let fromDate = partialRoute.regularStops?.first?.departureTime, let toDate = partialRoute.regularStops?.last?.arrivalTime {
            let currentDate = Date()
            let tDCurrentDate = CGFloat(toDate.seconds(from: currentDate))
            let tDDepartureDate = CGFloat(toDate.seconds(from: fromDate))
            let truncatedTDCurrentDate = max(0, min(tDDepartureDate, tDDepartureDate-tDCurrentDate))
            let percentage = truncatedTDCurrentDate / tDDepartureDate
            let y0 = visualBar.frame.center.y - visualBar.frame.height/2
            let y1 = y0 + visualBar.frame.height * percentage
            let x = visualBar.frame.center.x
            if pointView != nil {
                UIView.animate(withDuration: 5, animations: {
                    self.contentView.layoutIfNeeded()
                    self.pointView!.frame = CGRect(center: CGPoint(x: x, y: y1), size: CGSize(width: 14, height: 14))
                })
            } else {
                pointView = UIView(frame: CGRect(center: CGPoint(x: x, y: y1), size: CGSize(width: 14, height: 14)))
                pointView!.layer.cornerRadius = 7
                pointView!.backgroundColor = .white
                self.contentView.addSubview(pointView!)
            }
        }
    }
    
    func tearDown() {
        timer?.invalidate()
    }
}
