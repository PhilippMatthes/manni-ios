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

enum LocatorResponse {
    case success
    case linesCouldNotBeLoaded
    case routeStopsCouldNotBeLoaded
    case occurencesCouldNotBeLoaded
    case failure
}

class Locator {
    static func location(forRouteStop routeStop: Route.RouteStop,
                        completion: @escaping (_ success: Bool, _ result: CLLocation?) -> ()) {
        Stop.find(routeStop.name) {
            result in
            guard
                let response = result.success,
                let bestStop = response.stops.first,
                let location = bestStop.location
                else { completion(false, nil); return }
            completion(true, CLLocation(latitude: location.latitude, longitude: location.longitude)); return
        }
    }
    
    static func directions(forLineName lineName: String,
                           aroundStop stop: Stop,
                           completion: @escaping (_ success: Bool, _ result: [Line]) -> ()) {
        Line.get(forStopName: stop.name) {
            result in
            if let response = result.success {
                var filteredLines = [Line]()
                for responseLine in response.lines {
                    if responseLine.name == lineName {
                        filteredLines.append(responseLine)
                    }
                }
                completion(true, filteredLines)
            } else { completion(false, [Line]()); return }
        }
    }
    
    static func allstops(forLineName lineName: String,
                         startPointName: String,
                         endPointName: String,
                         completion: @escaping (_ success: Bool, _ result: [Route.RouteStop]?) -> ()) {
        Route.find(from: startPointName, to: endPointName) {
            result in
            if let response = result.success {
                for responseRoute in response.routes {
                    if responseRoute.interchanges == 0 && responseRoute.partialRoutes.count == 1 {
                        if let partialRoute = responseRoute.partialRoutes.first {
                            if let regularStops = partialRoute.regularStops {
                                completion(true, regularStops); return
                            }
                        }
                    }
                }
            } else { completion(false, nil); return }
        }
    }
    
    static func alloccurences(forLineName lineName: String,
                              direction: String,
                              routeStops: [Route.RouteStop],
                              completion: @escaping (_ success: Bool, _ result: [Route.RouteStop : [Departure]]) -> ()) {
        var output: [Route.RouteStop : [Departure]] = [Route.RouteStop : [Departure]]()
        let dispatchGroup = DispatchGroup()
        for stop in routeStops {
            dispatchGroup.enter()
            Departure.monitor(stopWithName: stop.name) {
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
            completion(true, output); return
        }
    }
    
    static func locate(lineName: String,
                       direction: String,
                       aroundStop stop: Stop,
                       completion: @escaping (_ success: LocatorResponse, _ result: [Route.RouteStop: [Departure]]?) -> ()) {
        Locator.directions(forLineName: lineName, aroundStop: stop) {
            success, lines in
            if !success { completion(.linesCouldNotBeLoaded, nil) }
            else if let line = lines.first {
                if line.directions.count > 1 {
                    let dispatchGroup = DispatchGroup()
                    var nextDepartures = [Route.RouteStop : [Departure]]()
                    for pair in Util.removeDupes(Util.permutations(line.directions, k: 2)) {
                        dispatchGroup.enter()
                        let startPointName = pair.first!.name
                        let endPointName = pair.last!.name
                        Locator.allstops(forLineName: lineName, startPointName: startPointName, endPointName: endPointName) {
                            success, routeStops in
                            if !success { dispatchGroup.leave() }
                            else if let routeStops = routeStops {
                                Locator.alloccurences(forLineName: lineName, direction: direction, routeStops: routeStops) {
                                    success, result in
                                    if !success { completion(.occurencesCouldNotBeLoaded, nil) } else {
                                        for (routeStop, departures) in result {
                                            if nextDepartures[routeStop] != nil {
                                                nextDepartures[routeStop]!.append(contentsOf: departures)
                                            } else {
                                                nextDepartures[routeStop] = departures
                                            }
                                        }
                                    }
                                    dispatchGroup.leave()
                                }
                            } else { dispatchGroup.leave() }
                        }
                    }
                    dispatchGroup.notify(queue: .main) { completion(.success, nextDepartures); return }
                } else { completion(.failure, nil); return }
            } else { completion(.failure, nil); return }
        }
        
    }
    
    static func filter(_ result: [Route.RouteStop : [Departure]], etaRange: Int=10) -> [Route.RouteStop : Departure] {
        var nextDepartures = [Route.RouteStop : Departure]()
        for (routeStop, departures) in result {
            var currentlyDeparting: Departure?
            for d in departures {
                if d.ETA < etaRange {
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
