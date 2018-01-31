//
//  MapViewExtension.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit
import DVB
import BRYXBanner
import Material
import Motion

extension MKMapView {
    func zoomFitOverlays() {
        if let first = overlays.first {
            let rect = overlays.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
            setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
        }
    }
    
    func showLocations(lineName: String,
                       direction: String,
                       stop: Stop,
                       etaRange: Int=Config.standardEtaRange,
                       zoomFit: Bool=true,
                       log: @escaping (_ text: String, _ detail: String?) -> ()) {
        log("Ortung für die Linie \(lineName) wird durchgeführt...", nil)
        Locator.locate(lineName: lineName, direction: direction, aroundStop: stop, log: log) {
            result in
            if let result = result {
                log("Erfolg!", "Daten zur Linie \(lineName) Richtg. \(direction) konnten an \(result.count) Orten gefunden werden.")
                let dispatchGroup = DispatchGroup()
                for (routeStop, departure) in Locator.filter(result) {
                    dispatchGroup.enter()
                    if let c = routeStop.coordinate {
                        let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                        self.add(location: location, departure: departure, etaRange: etaRange)
                        dispatchGroup.leave()
                    } else {
                        Locator.location(forRouteStop: routeStop, log: log) {
                            loc in
                            if let loc = loc { self.add(location: loc, departure: departure, etaRange: etaRange) }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) { if zoomFit{ self.zoomFitOverlays() } }
            }
        }
    }
    
    func add(location: CLLocation?, departure: Departure, etaRange: Int) {
        DispatchQueue.main.async {
            if let location = location {
                self.addCircle(location: location, departure: departure)
                if departure.ETA < etaRange { self.addAnnotation(location: location, departure: departure) }
            }
        }
    }
    
    func addAnnotation(location: CLLocation, departure: Departure, radius: CLLocationDistance=100){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = departure.description
        circle.subtitle = "Abfahrt der \(departure.line) in \(departure.ETA) min"
        self.addAnnotation(circle)
    }
    
    func addCircle(location: CLLocation, departure: Departure, radius: CLLocationDistance=100){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = String(departure.ETA)
        circle.subtitle = "Abfahrt der \(departure.line) in \(departure.ETA) min"
        self.add(circle, level: .aboveRoads)
    }
}
