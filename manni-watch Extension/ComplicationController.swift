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
    private var lastStopID: String?
    
    private var locationManager: CLLocationManager!
    
    private var lastScheduledRefreshDate: Date?
    
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
    
    func requestLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Background fetch was called. Tasks: \(backgroundTasks), State: \(WKExtension.shared().applicationState)")
        for task in backgroundTasks {
            if (WKExtension.shared().applicationState == .background) {
                print("Requesting location, because background fetch was called.")
                requestLocation()
                scheduleNextRefresh()
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
    
    func scheduleNextRefresh() {
        lastScheduledRefreshDate = (lastScheduledRefreshDate ?? Date()).addingTimeInterval(10 * 60)
        WKExtension.shared().delegate = self
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: lastScheduledRefreshDate!, userInfo: nil) {
            error in
            if let error = error {
                print("Error scheduling backgroundrefresh: \(error)")
            } else {
                print("Scheduled background refresh at: \(self.lastScheduledRefreshDate!)")
            }
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        scheduleNextRefresh()
        
        if departures.count == 0 {
            requestLocation()
            handler(nil)
            print("Requesting location, because there are no departures.")
            return
        }
        
        if let lastDate = departures.last?.realTime ?? departures.last?.scheduledTime, lastDate < date {
            requestLocation()
            handler(nil)
            print("Requesting location, because last loaded departure is before current date.")
            return
        }
        
        if let firstDate = departures.first?.realTime ?? departures.first?.scheduledTime, firstDate < Date(timeInterval: -5 * 60, since: Date()){
            requestLocation()
            print("Requesting location, because first loaded departure is dating 5 mins back.")
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
            
            let row1Column1Provider = CLKRelativeDateTextProvider(date: departure1.realTime ?? departure1.scheduledTime, style: .timer, units: [.minute, .second])
            if let state = departure1.state, state.rawValue == Departure.State.delayed.rawValue {
                row1Column1Provider.tintColor = UIColor(rgb: 0xff7675, alpha: 1.0)
            }
            
            template.row1Column1TextProvider = row1Column1Provider
            
            if let date = departure2?.realTime ?? departure2?.scheduledTime {
                let provider = CLKRelativeDateTextProvider(date: date, style: .timer, units: [.minute, .second])
                if let state = departure2?.state, state.rawValue == Departure.State.delayed.rawValue {
                    provider.tintColor = UIColor(rgb: 0xff7675, alpha: 1.0)
                }
                template.row2Column1TextProvider = provider
            } else {
                template.row2Column1TextProvider = CLKSimpleTextProvider(text: "-")
            }
            
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(departure1.line) \(departure1.direction)")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(departure2?.line ?? "-") \(departure2?.direction ?? "-")")
            
            let headerTextProvider = CLKSimpleTextProvider(text: stopName ?? "Kein Stopp.")
            headerTextProvider.tintColor = Colors.color(forInt: stopName?.count)
            template.headerTextProvider = headerTextProvider
            
            var date = Date()
            if i > 0 {
                date = departures[i - 1].realTime ?? departures[i - 1].scheduledTime
            }
            
            entries.append(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
        }
        
        print("Processed \(entries.count)/\(limit) timeline entries, currently caching the following departures for \(stopName ?? "n/a"): \(departures)")
        
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
        print("Location manager did fail with error: \(error)")
        locationManager(manager, didUpdateLocations: [location])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("Location manager did update locations, but transmitted no locations.")
            return
        }
        print("Location manager did update last location: \(location)")
        lastLocation = location
        let coord = WGSCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        guard let nearestStation = Station.nearestStations(coordinate: coord)?.first else {return}
        
        if lastStopID == nearestStation.id {
            if let lastDate = departures.last?.realTime ?? departures.last?.scheduledTime, lastDate > Date() {
                print("Decided to not perform a monitor request, because the stop didn't change and the last fetched departure is still in the future.")
                scheduleNextRefresh()
                return
            }
        }
        
        lastStopID = nearestStation.id
        
        print("Requesting stop with id: \(lastStopID)")
        Stop.find(nearestStation.id) {
            response in
            print("Server responded to find request with: Failure(\(response.failure)), Success(\(response.success))")
            if let success = response.success, let stop = success.stops.first {
                print("Performing monitor request on stop: \(stop.name)")
                stop.monitor() {
                    monitorResponse in
                    print("Server responded to find monitor request with: Failure(\(monitorResponse.failure)), Success(\(monitorResponse.success))")
                    guard let monitorSuccess = monitorResponse.success else {return}
                    self.departures = monitorSuccess.departures
                    self.stopName = monitorSuccess.stopName
                    self.updateComplication()
                }
            }
        }
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTable()
            
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "42")
            
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "12:34")
            
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "Delayed Arrival")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "Scheduled Arrival")
            
            let headerTextProvider = CLKSimpleTextProvider(text: "Stop")
            headerTextProvider.tintColor = Colors.color(forInt: "Stop".count)
            template.headerTextProvider = headerTextProvider
            
            handler(template)
        default:
            handler(nil)
        }
    }
    
}
