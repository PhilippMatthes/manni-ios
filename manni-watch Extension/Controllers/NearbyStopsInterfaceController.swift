//
//  NearbyStopsInterfaceController.swift
//  manni-watch Extension
//
//  Created by Philipp Matthes on 19.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit
import DVB
import CoreLocation

class NearbyStopsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    @IBOutlet var nearbyStopsTable: WKInterfaceTable!
    
    var stations = [Station]()
    
    let locationManager = CLLocationManager()
    
    override func willActivate() {
        super.willActivate()
        
        prepareLocationManager()
        self.locationManager.requestLocation()
        
        showCells(Config.determiningPosition)
    }
    
    func prepareLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func showCells(_ text: String...) {
        
        self.nearbyStopsTable.setNumberOfRows(text.count, withRowType: "NearbyStopRow")
        
        for i in 0..<text.count {
            guard let controller = self.nearbyStopsTable.rowController(at: i) as? StopRowController else { return }
            controller.label.setText(text[i])
        }
    }
    
    func showStations(aroundLocation loc: CLLocation) {
        let coord = WGSCoordinate(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        
        stations = Array(Station.nearestStations(coordinate: coord).prefix(15))
        if stations.count == 0 {
            showCells(Config.didNotFindAnyStations)
            return
        }
        
        self.nearbyStopsTable.setNumberOfRows(stations.count+1, withRowType: "NearbyStopRow")
        
        guard let controller = self.nearbyStopsTable.rowController(at: 0) as? StopRowController else { return }
        controller.label.setText(Config.refresh)
        
        for i in 0..<stations.count {
            guard let controller = self.nearbyStopsTable.rowController(at: i+1) as? StopRowController else { continue }
            let station = stations[i]
            let distance = Int(CLLocation(
                latitude: station.wgs84Lat,
                longitude: station.wgs84Long
                ).distance(from: loc))
            controller.group.setBackgroundColor(Colors.color(forInt: station.name.count))
            controller.label.setText("\(distance)m - \(station.nameWithLocation)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 { return }
        let loc = locations.first!
        // let loc = CLLocation(latitude: 51.0381358, longitude: 13.701056)
        showStations(aroundLocation: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showCells(
            Config.gpsPositionCouldNotBeAccessed,
            Config.pleaseActivateLocationServices
        )
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 0 || stations.count <= rowIndex {
            guard let controller = table.rowController(at: rowIndex) as? StopRowController else { return }
            controller.label.setText(Config.refreshing)
            locationManager.requestLocation()
        } else {
            guard let _ = table.rowController(at: rowIndex) as? StopRowController else { return }
            let station = stations[rowIndex-1]
            presentController(withName: "DeparturesInterfaceController", context: station)
        }
    }
    
}
