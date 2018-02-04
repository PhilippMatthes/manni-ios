//
//  PartialRouteExtension.swift
//  manni
//
//  Created by Philipp Matthes on 04.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB


extension Route.RoutePartial: Equatable {
    public static func ==(lhs: Route.RoutePartial, rhs: Route.RoutePartial) -> Bool {
        if let lhsId = lhs.partialRouteId, let rhsId = rhs.partialRouteId {
            return lhsId == rhsId
        } else if let lhsStops = lhs.regularStops, let rhsStops = rhs.regularStops {
            if lhsStops.count != rhsStops.count { return false }
            for (lhsStop, rhsStop) in zip(lhsStops, rhsStops) {
                if lhsStop != rhsStop { return false }
            }
            return true
        } else {
            if let lhsDuration = lhs.duration, let rhsDuration = rhs.duration {
                if lhsDuration != rhsDuration { return false }
            }
            if lhs.shift != rhs.shift { return false }
            return lhs.mode == rhs.mode
        }
    }
}

extension Route.ModeElement: Equatable {
    public static func ==(lhs: Route.ModeElement, rhs: Route.ModeElement) -> Bool {
        if let lhsChanges = lhs.changes, let rhsChanges = rhs.changes {
            return lhsChanges == rhsChanges
        } else if let lhsDirection = lhs.direction, let rhsDirection = rhs.direction {
            return lhsDirection == rhsDirection
        } else if let lhsName = lhs.name, let rhsName = rhs.name {
            return lhsName == rhsName
        } else {
            return true
        }
    }
}
