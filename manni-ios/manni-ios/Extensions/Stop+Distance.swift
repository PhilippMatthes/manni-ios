//
//  Stop+Distance.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 04.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB
import CoreLocation

extension Stop {
    
    public func distance(from currentLocation: CLLocation) -> Int? {
        guard let destination = location else {return nil}
        let latitude = destination.latitude
        let longitude = destination.longitude
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        return Int(coordinate.distance(from: currentLocation))
    }
    
}
