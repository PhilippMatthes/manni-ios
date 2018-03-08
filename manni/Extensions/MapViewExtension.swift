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
            DispatchQueue.main.async {
                self.setVisibleMapRect (
                    rect,
                    edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                    animated: true
                )
            }
        }
    }
    
    func showLocations(tripId: String,
                       stopId: String,
                       etaRange: Int=Config.standardEtaRange,
                       zoomFit: Bool=true,
                       log: @escaping (_ text: String, _ detail: String?) -> (),
                       completion: @escaping () -> ()) {
        log("Ortung wird durchgeführt...", nil)
        let date = Date()
        TripStop.get(forTripID: tripId, stopID: stopId, atTime: date) {
            result in
            guard let success = result.success else {
                log("Ihre Linie konnte nicht gefunden werden", nil)
                return
            }
            self.removeOverlays(self.overlays)
            self.removeAnnotations(self.annotations)
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
                        log("Ihre Linie konnte nicht gefunden werden", nil)
                        return
                    }
                    let location = CLLocation(latitude: wgs.latitude, longitude: wgs.longitude)
                    self.addAnnotation(location: location, stopName: stop.name) {
                        self.addCircle(location: location) {
                            self.zoomFitOverlays()
                            log("Ihre Linie wurde gefunden!", nil)
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func addAnnotation(location: CLLocation,
                       stopName: String,
                       radius: CLLocationDistance=100,
                       completion: @escaping () -> ()) {
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = "Ihre Linie befindet sich aktuell an der Hst. \(stopName)"
        DispatchQueue.main.async {
            self.addAnnotation(circle)
            completion()
        }
    }
    
    func addCircle(location: CLLocation,
                   radius: CLLocationDistance=100,
                   completion: @escaping () -> ()) {
        let circle = MKCircle(center: location.coordinate, radius: radius)
        DispatchQueue.main.async {
            self.add(circle, level: .aboveRoads)
            completion()
        }
    }
}
