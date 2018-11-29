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
    
    @IBOutlet var indicator: WKInterfaceImage!
    @IBOutlet var nearbyStopsTable: WKInterfaceTable!
    
    var stations = [Station]()
    
    let locationManager = CLLocationManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        update()
    }
    
    func startAnimatingLoading() {
        self.nearbyStopsTable.setHidden(true)
        self.indicator.setHidden(false)
        self.indicator.setImageNamed("satellit")
        self.indicator.startAnimating()
    }
    
    func stopAnimatingLoading() {
        self.indicator.setHidden(true)
        self.nearbyStopsTable.setHidden(false)
        self.indicator.stopAnimating()
        self.indicator.setImage(nil)
    }
    
    @IBAction func refreshButtonPressed() {
        update()
    }
    
    func update() {
        self.startAnimatingLoading()
        prepareLocationManager()
        self.locationManager.requestLocation()
    }
    
    func prepareLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func showPrompt() {
        let action1 = WKAlertAction(title: Config.refresh, style: .default) {
            self.update()
        }
        let action2 = WKAlertAction(title: Config.cancel, style: .destructive) {}
        presentAlert(withTitle: Config.thereWasAProblemDownloading, message: "", preferredStyle: .actionSheet, actions: [action1,action2])
    }
    
    func showNavigationServicesPrompt() {
        let action1 = WKAlertAction(title: Config.refresh, style: .default) {
            self.update()
        }
        let action2 = WKAlertAction(title: Config.cancel, style: .destructive) {}
        presentAlert(withTitle: Config.gpsPositionCouldNotBeAccessed + " " + Config.pleaseActivateLocationServices, message: "", preferredStyle: .actionSheet, actions: [action1, action2])
    }
    
    func showStations(aroundLocation loc: CLLocation) {
        let coord = WGSCoordinate(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        
        guard let nearestStations = Station.nearestStations(coordinate: coord)?.prefix(100) else {return}
        
        stations = Array(nearestStations)
        if stations.count == 0 {
            self.showPrompt()
            return
        }
        
        if self.nearbyStopsTable.numberOfRows != stations.count {
            self.nearbyStopsTable.setNumberOfRows(stations.count, withRowType: "NearbyStopRow")
        }
        
        for i in 0..<stations.count {
            guard let controller = self.nearbyStopsTable.rowController(at: i) as? StopRowController else { continue }
            let station = stations[i]
            let distance = Int(CLLocation(
                latitude: station.wgs84Lat,
                longitude: station.wgs84Long
            ).distance(from: loc))
            controller.group.setBackgroundColor(Colors.color(forInt: station.name.count))
            controller.label.setText("\(station.name)")
            controller.distanceLabel.setText("\(distance)m")
        }
        
        stopAnimatingLoading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {return}
//        let loc = CLLocation(latitude: 51.0381358, longitude: 13.701056)
        showStations(aroundLocation: loc)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showNavigationServicesPrompt()
        return
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

        let station = stations[rowIndex]
        presentController(withName: "DeparturesInterfaceController", context: station)
    }
    
}
