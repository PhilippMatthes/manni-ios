//
//  Section.swift
//  manni
//
//  Created by Philipp Matthes on 03.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

struct RouteSection {
    var start: String!
    var end: String!
    var expanded: Bool!
    var route: Route!
    
    init(start: String, end: String, expanded: Bool, route: Route) {
        self.start = start; self.end = end; self.expanded = expanded; self.route = route
    }
}
