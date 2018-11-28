//
//  LocationInterfaceController.swift
//  manni-watch Extension
//
//  Created by Philipp Matthes on 31/5/18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit
import DVB

class LocationInterfaceController: WKInterfaceController {
    @IBOutlet var indicator: WKInterfaceImage!
    @IBOutlet var map: WKInterfaceMap!
    @IBOutlet var tempPicker: WKInterfacePicker!
    
    var zoomArray:[Double] = [1.0,0.98,0.96,0.94,0.92,0.90,0.88,0.86,0.84,0.82,0.80,0.78,0.76,0.74,0.72,0.70,0.68,0.66,0.64,0.62,0.60,0.58,0.56,0.54,0.52,0.50,0.48,0.46,0.44,0.42,0.40,0.38,0.36,0.34,0.32,0.30,0.28,0.26,0.24,0.22,0.20,0.18,0.16,0.14,0.12,0.10,0.09,0.08,0.07,0.06,0.05,0.04,0.03,0.02,0.01,0.009,0.008,0.007,0.006,0.005,0.004,0.003,0.002,0.001]
    
    var coordinate: CLLocationCoordinate2D?
    
    override func awake(withContext context: Any?) {
        guard let context = context as? [String] else { return }
        let stopId = context[0]
        let tripId = context[1]
        
        let pickerItems: [WKPickerItem] = zoomArray.map {
            let pickerItem = WKPickerItem()
            pickerItem.caption = String($0)
            pickerItem.title = String($0)
            return pickerItem
        }
        
        self.tempPicker.setItems(pickerItems)
        self.tempPicker.setSelectedItemIndex(25)
        
        let span = MKCoordinateSpanMake(zoomArray[25], zoomArray[25])
        
        self.startAnimatingLoading()
        
        showLocations(tripId: tripId, stopId: stopId, labelUpdates: {
            text in
        }) {
            coordinate in
            self.coordinate = coordinate
            DispatchQueue.main.async {
                self.map.addAnnotation(coordinate, with: .red)
                self.map.zoomFit(coordinate: coordinate, span: span)
                self.stopAnimatingLoading()
            }
        }
    }
    
    func startAnimatingLoading() {
        self.map.setHidden(true)
        self.indicator.setHidden(false)
        self.indicator.setImageNamed("satellit")
        self.indicator.startAnimating()
    }
    
    func stopAnimatingLoading() {
        self.indicator.setHidden(true)
        self.map.setHidden(false)
        self.indicator.stopAnimating()
        self.indicator.setImage(nil) 
    }
    
    func showLocations(tripId: String,
                       stopId: String,
                       zoomFit: Bool=true,
                       labelUpdates: @escaping (String) -> (),
                       completion: @escaping (CLLocationCoordinate2D) -> ()) {
        labelUpdates(Config.locating)
        let date = Date()
        TripStop.get(forTripID: tripId, stopID: stopId, atTime: date) {
            result in
            guard let success = result.success else {
                labelUpdates(Config.lineCouldNotBeFound)
                return
            }
            DispatchQueue.main.async {
                self.map.removeAllAnnotations()
            }
            if let currentStop = success.stops
                .sorted(by: {abs($0.time.seconds(from: date)) < abs($1.time.seconds(from: date))})
                .first {
                Stop.find(currentStop.id) {
                    result in
                    guard
                        let success = result.success,
                        let stop = success.stops.first,
                        let wgs = stop.location
                        else {
                            labelUpdates(Config.lineCouldNotBeFound)
                            return
                    }
                    let location = CLLocation(latitude: wgs.latitude, longitude: wgs.longitude)
                    labelUpdates(Config.lineWasFound)
                    completion(location.coordinate)
                }
            }
        }
    }
    @IBAction func pickerChanged(_ value: Int) {
        guard let coordinate = self.coordinate else {return}
        let span = MKCoordinateSpanMake(zoomArray[value], zoomArray[value])
        let region = MKCoordinateRegionMake(coordinate, span)
        map.setRegion(region)
        tempPicker.focus()
    }

}
