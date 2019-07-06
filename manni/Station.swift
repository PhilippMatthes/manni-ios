//
//  CoordinateTools.swift
//  manni
//
//  Created by Philipp Matthes on 19.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation
import DVB

class Station {
    
    var id: String
    var nameWithLocation: String
    var name: String
    var location: String
    var wgs84Lat: Double
    var wgs84Long: Double
    
    private static var cachedStations: [Station]?
    
    init(
        id: String,
        nameWithLocation: String,
        name: String,
        location: String,
        wgs84Lat: Double,
        wgs84Long: Double
    ) {
        self.id = id
        self.nameWithLocation = nameWithLocation
        self.name = name
        self.location = location
        self.wgs84Lat = wgs84Lat
        self.wgs84Long = wgs84Long
    }
    
    static func loadAllStations() -> [Station]? {
        if cachedStations != nil {
            return cachedStations
        }
        guard
            let data = CSV.readDataFromCSV(fileName: "stations", fileType: "csv")
        else {return nil}
        var stationsCSV = CSV.csv(data: data)
        stationsCSV.removeFirst()
        
        var stations = [Station]()
        for csv in stationsCSV {
            if csv.count != 9 { continue }
            let id = csv[0]
            let nameWithLocation = csv[1]
            let name = csv[2]
            let location = csv[3]
            autoreleasepool {
                let wgs84Long = Double(csv[7].replacingOccurrences(of: ",", with: "."))!
                let wgs84Lat = Double(csv[8].replacingOccurrences(of: ",", with: "."))!
                stations.append(Station(id: id, nameWithLocation: nameWithLocation, name: name, location: location, wgs84Lat: wgs84Lat, wgs84Long: wgs84Long))
            }
        }
        
        cachedStations = stations
        
        return stations
    }
    
    static func nearestStations(coordinate wgs: WGSCoordinate) -> [Station]? {
        guard let allStations = loadAllStations() else {return nil}
        let stationsWithDistance = allStations.map {
            ($0.distance(wgs), $0)
        }
        let stationsSorted = stationsWithDistance.sorted {
            $0.0 < $1.0
        }.map {
            $0.1
        }
        return stationsSorted
    }
    
    func asCLL() -> CLLocation {
        return CLLocation(latitude: self.wgs84Lat, longitude: self.wgs84Long)
    }
    
    func distance(_ wgs: WGSCoordinate) -> Double {
        return asCLL().distance(from: CLLocation(latitude: wgs.latitude, longitude: wgs.longitude))
    }
    
}

extension Station: Hashable {
    static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
