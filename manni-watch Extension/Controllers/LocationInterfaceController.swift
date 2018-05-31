//
//  LocationInterfaceController.swift
//  manni-watch Extension
//
//  Created by Philipp Matthes on 31/5/18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit
import DVB

class LocationInterfaceController: WKInterfaceController {
    @IBOutlet var map: WKInterfaceMap!
    @IBOutlet var label: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        guard let context = context as? [String] else { return }
        let stopId = context[0]
        let tripId = context[1]
        
        super.willActivate()
        showLocations(tripId: tripId, stopId: stopId, labelUpdates: {
            text in
            DispatchQueue.main.async {
                self.label.setText(text)
            }
        }) {}
    }
    
    func showLocations(tripId: String,
                       stopId: String,
                       zoomFit: Bool=true,
                       labelUpdates: @escaping (String) -> (),
                       completion: @escaping () -> ()) {
        labelUpdates(Config.locating)
        let date = Date()
        TripStop.get(forTripID: tripId, stopID: stopId, atTime: date) {
            result in
            guard let success = result.success else {
                labelUpdates(Config.lineCouldNotBeFound)
                return
            }
            DispatchQueue.main.async {
                self.map.removeAllAnnotations()
            }
            if let currentStop = success.stops
                .sorted(by: {abs($0.time.seconds(from: date)) < abs($1.time.seconds(from: date))})
                .first {
                Stop.find(currentStop.id) {
                    result in
                    guard
                        let success = result.success,
                        let stop = success.stops.first,
                        let wgs = stop.location
                        else {
                            labelUpdates(Config.lineCouldNotBeFound)
                            return
                    }
                    let location = CLLocation(latitude: wgs.latitude, longitude: wgs.longitude)
                    DispatchQueue.main.async {
                        self.map.addAnnotation(location.coordinate, with: .red)
                        self.map.zoomFit(coordinate: location.coordinate)
                    }
                    labelUpdates(Config.lineWasFound)
                    completion()
                }
            }
        }
    }
}
