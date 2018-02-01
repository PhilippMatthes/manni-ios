//
//  RouteExtension.swift
//  manni
//
//  Created by Philipp Matthes on 28.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import MapKit


class Locator {
    static func location(forRouteStop routeStop: Route.RouteStop,
                         log: @escaping (_ text: String, _ detail: String) -> (),
                         completion: @escaping (_ result: CLLocation?) -> ()) {
        Stop.find(routeStop.name) {
            result in
            guard let r = result.success, let b = r.stops.first, let l = b.location else { return }
            completion(CLLocation(latitude: l.latitude, longitude: l.longitude))
        }
    }
    
    static func directions(forLineName lineName: String,
                           aroundStop stopName: String,
                           log: @escaping (_ text: String, _ detail: String?) -> (),
                           completion: @escaping (_ result: [String]?) -> ()) {
        log("Finde mögliche Richtungen der linie \(lineName)", nil)
        Line.get(forStopName: stopName) {
            result in
            if let response = result.success {
                var filteredLines = [String]()
                for responseLine in response.lines {
                    if responseLine.name == lineName {
                        for direction in responseLine.directions {
                            filteredLines.append(direction.name)
                        }
                    }
                }
                if filteredLines.count == 1 {
                    filteredLines.append(stopName)
                }
                log("Es wurden \(filteredLines.count) verschiedene Richtungen gefunden.",
                    "\(filteredLines)")
                completion(filteredLines)
            } else {
                log("Keine Richtungen für die Linie \(lineName) an der Hst. \(stopName) gefunden", nil)
            }
        }
    }
    
    static func allstops(forLineName lineName: String,
                         startPointName: String,
                         endPointName: String,
                         log: @escaping (_ text: String, _ detail: String?) -> (),
                         completion: @escaping (_ result: [Route.RouteStop]?) -> ()) {
        log("Suche alle Haltestellen der Linie \(lineName)", "Zwischen \(startPointName) und \(endPointName)")
        Route.find(from: startPointName, to: endPointName) {
            result in
            if let response = result.success {
                for responseRoute in response.routes.sorted(by: {$0.interchanges < $1.interchanges}) {
                    let regularStops = responseRoute.partialRoutes
                        .map({ $0.regularStops })
                        .flatMap({ $0 })
                        .flatMap({ $0 })
                    log("\(regularStops.count) Haltestellen gefunden", "Zwischen \(startPointName) und \(endPointName)")
                    completion(regularStops)
                    return
                }
            } else {
                log("Keine Haltestellen der Linie \(lineName) gefunden", "Zwischen \(startPointName) und \(endPointName)")
            }
        }
    }
    
    static func alloccurences(forLineName lineName: String,
                              direction: String,
                              routeStops: [Route.RouteStop],
                              log: @escaping (_ text: String, _ detail: String?) -> (),
                              completion: @escaping (_ result: [Route.RouteStop : [Departure]]) -> ()) {
        var output: [Route.RouteStop : [Departure]] = [Route.RouteStop : [Departure]]()
        let dispatchGroup = DispatchGroup()
        log("Suche alle Daten zur Linie \(lineName) \(direction)", "Lade Live-Fahrplanmonitor von \(routeStops.count) Haltestellen")
        for stop in routeStops {
            dispatchGroup.enter()
            Departure.monitor(stopWithId: stop.dataId) {
                result in
                if let response = result.success {
                    for departure in response.departures {
                        if departure.line == lineName && departure.direction == direction {
                            if output[stop] != nil {
                                output[stop]!.append(departure)
                            } else {
                                output[stop] = [departure]
                            }
                        }
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            log("Daten zur Linie \(lineName) \(direction) wurden heruntergeladen", "Daten für \(output.count) Haltestellen gefunden")
            completion(output)
        }
    }
    
    static func locate(lineName: String,
                       direction: String,
                       aroundStop stop: Stop,
                       log: @escaping (_ text: String, _ detail: String?) -> (),
                       completion: @escaping (_ result: [Route.RouteStop: [Departure]]?) -> ()) {
        Locator.directions(forLineName: lineName, aroundStop: stop.name, log: log) {
            directions in
            if let directions = directions {
                if directions.count > 1 {
                    let dispatchGroup = DispatchGroup()
                    var nextDepartures = [Route.RouteStop : [Departure]]()
                    for pair in Util.removeDupes(Util.permutations(directions, k: 2)) {
                        dispatchGroup.enter()
                        let startPointName = pair.first!
                        let endPointName = pair.last!
                        Locator.allstops(forLineName: lineName, startPointName: startPointName, endPointName: endPointName, log: log) {
                            routeStops in
                            if let routeStops = routeStops {
                                Locator.alloccurences(forLineName: lineName, direction: direction, routeStops: routeStops, log: log) {
                                    occurences in
                                    for (routeStop, departures) in occurences {
                                        if nextDepartures[routeStop] != nil {
                                            nextDepartures[routeStop]!.append(contentsOf: departures)
                                        } else {
                                            nextDepartures[routeStop] = departures
                                        }
                                    }
                                    dispatchGroup.leave()
                                }
                            } else { dispatchGroup.leave() }
                        }
                    }
                    dispatchGroup.notify(queue: .main) { completion(nextDepartures) }
                }
            }
        }
    }
    
    static func filter(_ result: [Route.RouteStop : [Departure]]) -> [Route.RouteStop : Departure] {
        var nextDepartures = [Route.RouteStop : Departure]()
        for (routeStop, departures) in result {
            var currentlyDeparting: Departure?
            for d in departures {
                if currentlyDeparting != nil {
                    if currentlyDeparting!.ETA > d.ETA {
                        currentlyDeparting = d
                    }
                } else {
                    currentlyDeparting = d
                }
            }
            if let c = currentlyDeparting {
                nextDepartures[routeStop] = c
            }
        }
        return nextDepartures
    }
}
