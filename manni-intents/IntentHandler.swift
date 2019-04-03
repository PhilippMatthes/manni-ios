//
//  IntentHandler.swift
//  manni-intents
//
//  Created by Philipp Matthes on 03.04.19.
//  Copyright © 2019 Philipp Matthes. All rights reserved.
//

import Intents
import DVB

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is GetCurrentDeparturesOfLineAtStopIntent else {
            fatalError("Unhandled intent type")
        }
        
        return GetCurrentDeparturesIntentHandler()
    }
    
}

class GetCurrentDeparturesIntentHandler: NSObject, GetCurrentDeparturesOfLineAtStopIntentHandling {
    
    func handle(intent: GetCurrentDeparturesOfLineAtStopIntent, completion: @escaping (GetCurrentDeparturesOfLineAtStopIntentResponse) -> Void) {
        if let line = intent.line, let stopName = intent.stop {
            Stop.find(stopName) {
                result in
                self.handle(findResult: result, line: line, completion: completion)
                return
            }
        }
        if let line = intent.line, let placemark = intent.location {
            if let coordinate = placemark.location?.coordinate {
                Stop.findNear(lat: coordinate.latitude, lng: coordinate.longitude) {
                    result in
                    self.handle(findResult: result, line: line, completion: completion)
                    return
                }
            }
            if let name = placemark.name {
                Stop.find(name) {
                    result in
                    self.handle(findResult: result, line: line, completion: completion)
                    return
                }
            }
        }
        if let stopName = intent.stop {
            Stop.find(stopName) {
                result in
                self.handle(findResult: result, completion: completion)
                return
            }
        }
        if let placemark = intent.location {
            if let coordinate = placemark.location?.coordinate {
                Stop.findNear(lat: coordinate.latitude, lng: coordinate.longitude) {
                    result in
                    self.handle(findResult: result, completion: completion)
                    return
                }
            }
            if let name = placemark.name {
                Stop.find(name) {
                    result in
                    self.handle(findResult: result, completion: completion)
                    return
                }
            }
        }
    }
    
    func handle(findResult result: Result<FindResponse>, line: String? = nil, completion: @escaping (GetCurrentDeparturesOfLineAtStopIntentResponse) -> Void) {
        let failure = GetCurrentDeparturesOfLineAtStopIntentResponse(code: .failure, userActivity: nil)
        guard let success = result.success, let stop = success.stops.first else {completion(failure); return}
        Departure.monitor(stopWithId: stop.id) {
            response in
            guard let success = response.success else {completion(failure); return}
            var departures: [String]
            if let line = line {
                let filteredDepartures = success.departures
                    .filter {$0.line.contains(line)}
                guard let firstDirection = filteredDepartures.first?.direction else {return}
                if (!filteredDepartures.map {$0.direction == firstDirection}.contains(false)) {
                    departures = filteredDepartures.map {$0.shortTime}
                } else {
                    departures = filteredDepartures.map {$0.shortTimedDescription}
                }
            } else {
                departures = success.departures
                    .map {$0.localizedDescription}
            }
            completion(GetCurrentDeparturesOfLineAtStopIntentResponse.success(stop: stop.description, departures: departures))
        }
    }
    
}

extension Departure {
    var localizedDescription: String {
        get {
            return "\(self.line) \(self.direction) in \(self.ETA) \(Config.minutes)"
        }
    }
    
    var shortTimedDescription: String {
        get {
            return "in \(self.ETA) \(Config.minutes) \(Config.direction) \(self.direction)"
        }
    }
    
    var shortTime: String {
        get {
            return "in \(self.ETA) \(Config.minutes)"
        }
    }
}
