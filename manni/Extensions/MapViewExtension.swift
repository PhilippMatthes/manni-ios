//  MIT License
//
//  Copyright (c) 2018 Philipp Matthes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
                       stopName: String,
                       etaRange: Int=Config.standardEtaRange,
                       zoomFit: Bool=true,
                       log: @escaping (_ text: String, _ detail: String?) -> (),
                       completion: @escaping () -> ()) {
        log("Ortung für die Linie \(lineName) wird durchgeführt...", nil)
        Locator.locate(lineName: lineName, direction: direction, aroundStopName: stopName, log: log) {
            result in
            self.removeOverlays(self.overlays)
            self.removeAnnotations(self.annotations)
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
                dispatchGroup.notify(queue: .main) { if zoomFit{ self.zoomFitOverlays(); completion() } }
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
        circle.title = "Abfahrt der \(departure.line) in \(departure.ETA) min"
        self.addAnnotation(circle)
    }
    
    func addCircle(location: CLLocation, departure: Departure, radius: CLLocationDistance=100){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = String(departure.ETA)
        circle.subtitle = "Abfahrt der \(departure.line) in \(departure.ETA) min"
        self.add(circle, level: .aboveRoads)
    }
}
