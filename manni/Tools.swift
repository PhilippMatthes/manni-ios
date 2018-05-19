//
//  Tools.swift
//  manni
//
//  Created by Philipp Matthes on 06.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class Tools {
    static func lastDepartureDate(fromRoute route: Route) -> Date? {
        let times = route.partialRoutes
            .compactMap { $0 }
            .filter { $0.regularStops != nil }
            .flatMap { $0.regularStops! }
            .map { [$0.arrivalTime, $0.departureTime] }
            .flatMap { $0 }
        let sortedTimes = times.sorted { $0 < $1 }
        return sortedTimes.last
    }
    
    static func lastDepartureDate(fromRoutes routes: [ExpandedRoute]) -> Date? {
        return routes
            .map { lastDepartureDate(fromRoute: $0.route)! }
            .sorted { $0 < $1 }
            .last
    }
}
