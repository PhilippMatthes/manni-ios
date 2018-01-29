//
//  RouteExtension.swift
//  manni
//
//  Created by Philipp Matthes on 28.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class Locator {
    static func directions(forLineName lineName: String,
                           aroundStop stop: Stop,
                           completion: @escaping (_ result: [Line]) -> ()) {
        Line.get(forStopName: stop.name) { result in
            guard let response = result.success else { return }
            var filteredLines = [Line]()
            for responseLine in response.lines {
                if responseLine.name == lineName {
                    filteredLines.append(responseLine)
                }
            }
            completion(filteredLines)
        }
    }
    
    static func allstops(forLineName lineName: String,
                         startPointName: String,
                         endPointName: String,
                         completion: @escaping (_ result: [Route.RouteStop]?) -> ()) {
        Route.find(from: startPointName, to: endPointName) { result in
            guard let response = result.success else { return }
            for responseRoute in response.routes {
                if responseRoute.interchanges == 0 && responseRoute.partialRoutes.count == 1 {
                    if let partialRoute = responseRoute.partialRoutes.first {
                        if let regularStops = partialRoute.regularStops {
                            completion(regularStops)
                            break
                        }
                    }
                }
            }
            completion(nil)
        }
    }
    
    static func alloccurences(forLineName lineName: String,
                              direction: String,
                              routeStops: [Route.RouteStop],
                              completion: @escaping (_ stop: String, _ departure: Departure) -> ()) {
        for stop in routeStops {
            Departure.monitor(stopWithName: stop.name) { result in
                guard let response = result.success else { return }
                for departure in response.departures {
                    if departure.line == lineName && departure.direction == direction {
                        print("Abfahrt der Linie \(lineName) \(direction) an \(stop.name): \(departure.scheduledTime)")
                    }
                }
            }
        }
    }
}
