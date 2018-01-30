//
//  RouteStopExtension.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

extension Route.RouteStop: Hashable {
    public var hashValue: Int {
        return self.name.hashValue
    }
    
    public static func ==(lhs: Route.RouteStop, rhs: Route.RouteStop) -> Bool {
        return lhs.name == rhs.name
    }
}
