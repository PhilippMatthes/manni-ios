//
//  ComplicationController.swift
//  temp Extension
//
//  Created by Philipp Matthes on 02.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import ClockKit
import DVB
import CoreLocation
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource, WKExtensionDelegate {
    
    // MARK: - Timeline Configuration
    
    private var departures = [Departure]()
    private var stopName: String?
    
    private var lastLocation: CLLocation?
    
    private var locationManager = CLLocationManager()
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func updateComplication() {
        let server = CLKComplicationServer.sharedInstance()
        guard
            let complications = server.activeComplications
        else {return}
        for complication in complications {
            server.reloadTimeline(for: complication)
        }
    }
    
    func refresh() {
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if (WKExtension.shared().applicationState == .background) {
                refresh()
            }
            task.setTaskCompleted()
        }
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(departures.last?.realTime ?? departures.last?.scheduledTime)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        print("Get \(limit) timeline entries, currently caching \(departures)")
        
        if departures.count == 0 {
            refresh()
            handler(nil)
            return
        }
        
        if let lastDate = departures.last?.realTime ?? departures.last?.scheduledTime, lastDate < date {
            refresh()
            handler(nil)
            return
        }
        
        var entries = [CLKComplicationTimelineEntry]()
        
        for (i, departure1) in self.departures.enumerated() {
            
            if departure1.realTime ?? departure1.scheduledTime < date {
                continue
            }
            
            if entries.count >= limit {
                break
            }
            
            var departure2: Departure?
            if i < self.departures.count - 1 {
                departure2 = self.departures[i + 1]
            }
            let template = CLKComplicationTemplateModularLargeTable()
            
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(departure1.line) \(departure1.direction)")
            template.row1Column1TextProvider = CLKRelativeDateTextProvider(date: departure1.realTime ?? departure1.scheduledTime, style: .timer, units: [.minute, .second])
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(departure2?.line ?? "-") \(departure2?.direction ?? "-")")
            if let date = departure2?.realTime ?? departure2?.scheduledTime {
                template.row2Column1TextProvider = CLKRelativeDateTextProvider(date: date, style: .timer, units: [.minute, .second])
            } else {
                template.row2Column1TextProvider = CLKSimpleTextProvider(text: "-")
            }
            
            let headerTextProvider = CLKSimpleTextProvider(text: stopName ?? "Kein Stopp.")
            headerTextProvider.tintColor = Colors.color(forInt: stopName?.count)
            template.headerTextProvider = headerTextProvider
            
            var date = Date()
            if i > 0 {
                date = departures[i - 1].realTime ?? departures[i - 1].scheduledTime
            }
            
            entries.append(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
        }
        
        for entry in entries {
            print(entry.date)
        }
        
        handler(entries)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        getTimelineEntries(for: complication, after: Date(), limit: 1) {
            entries in
            handler(entries?.first)
        }
    }

    
}

extension ComplicationController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let location = lastLocation else {return}
        print(location.coordinate)
        lastLocation = location
        let coord = WGSCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        guard let nearestStation = Station.nearestStations(coordinate: coord)?.first else {return}
        
        Stop.find(nearestStation.id) {
            response in
            if let success = response.success, let stop = success.stops.first {
                stop.monitor() {
                    monitorResponse in
                    guard let monitorSuccess = monitorResponse.success else {return}
                    self.departures = monitorSuccess.departures
                    self.stopName = monitorSuccess.stopName
                    self.updateComplication()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        print(location.coordinate)
        lastLocation = location
        let coord = WGSCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        guard let nearestStation = Station.nearestStations(coordinate: coord)?.first else {return}
        
        Stop.find(nearestStation.id) {
            response in
            if let success = response.success, let stop = success.stops.first {
                stop.monitor() {
                    monitorResponse in
                    guard let monitorSuccess = monitorResponse.success else {return}
                    self.departures = monitorSuccess.departures
                    self.stopName = monitorSuccess.stopName
                    self.updateComplication()
                }
            }
        }
    }
    
}
