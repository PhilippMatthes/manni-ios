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
    
    public func approximateDistance(
        from currentLocation: CLLocation,
        accuracy: Int = Int(kCLLocationAccuracyHundredMeters)
    ) -> Int? {
        guard let destination = location else {return nil}
        let latitude = destination.latitude
        let longitude = destination.longitude
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        return coordinate.approximateDistance(from: currentLocation, accuracy: accuracy)
    }
    
}

extension CLLocation {
    
    public func approximateDistance(
        from currentLocation: CLLocation,
        accuracy: Int = Int(kCLLocationAccuracyHundredMeters)
    ) -> Int {
        guard accuracy != 0 else {return Int(self.distance(from: currentLocation))}
        return Int(self.distance(from: currentLocation) / Double(accuracy)) * accuracy
    }
    
}
