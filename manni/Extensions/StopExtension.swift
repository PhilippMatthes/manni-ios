//
//  StopExtension.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

extension Stop {
    
    init(id: String, name: String, region: String?, location: WGSCoordinate?) {
        self.id = id; self.name = name; self.region = region; self.location = location
    }
    
    init(id: String, name: String, region: String?, longitude: Double?, latitude: Double?) {
        self.id = id; self.name = name; self.region = region
        let location = longitude != nil && latitude != nil ? GKCoordinate(x: longitude!, y: latitude!).asWGS : nil
        self.location = location
    }
    
}
