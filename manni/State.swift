//
//  Stations.swift
//  manni
//
//  Created by Philipp Matthes on 26.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class State {
    
    static let shared = State()
    var routeChanges = [String : [String]]()
    var stopQuery: String?
    var departure: Departure?
    var from: String?
    var to: String?
    var route: Route?
    
    var searchMode: SearchController.SearchMode {
        get {
            guard let searchMode = UserDefaults.loadObject(ofType: String(), withIdentifier: "searchMode") else {return .stop}
            return SearchController.SearchMode(rawValue: searchMode) == nil ? .stop : SearchController.SearchMode(rawValue: searchMode)!
        }
        set(new) {
            UserDefaults.save(object: new.rawValue, withIdentifier: "searchMode")
        }
    }
    
    var predictionsActive: Bool {
        get {
            guard let predictionsActiveFromStorage = UserDefaults.loadObject(ofType: Bool(), withIdentifier: "predictionsActive") else {return true}
            return predictionsActiveFromStorage
        }
        set(new) {
            UserDefaults.save(object: new, withIdentifier: "predictionsActive")
        }
    }
    
    var logData: [String : [Date]] {
        get {
            if let decoded = UserDefaults.loadObject(ofType: [String : [Date]](), withIdentifier: "logData") {return decoded}
            return [String : [Date]]()
        }
        set(new) {
            UserDefaults.save(object: new, withIdentifier: "logData")
        }
    }
    
    private init() {}
    
    func addLogData(_ queries: String?...) {
        let date = Date()
        for query in queries where query != nil {
            if logData[query!] != nil {logData[query!]!.append(date)}
            else {logData[query!] = [date]}
        }
    }
    
}

extension State {
    func loadRouteChanges() {
        RouteChange.get { result in
            guard let response = result.success else { return }
            for change in response.changes {
                
                var description: String
                switch change.kind.rawValue {
                case RouteChange.Kind.AmplifyingTransport.rawValue:
                    description = "Verstärkter Transport: "
                case RouteChange.Kind.Scheduled.rawValue:
                    description = "Geplante Änderung: "
                case RouteChange.Kind.ShortTerm.rawValue:
                    description = "Kurzfristige Änderung: "
                default:
                    description = ""
                }
                
                if var existingChanges = self.routeChanges[change.id] {
                    existingChanges.append("\(description)\(change.description)")
                    self.routeChanges[change.id] = existingChanges
                } else {
                    self.routeChanges[change.id] = ["\(description)\(change.description)"]
                }
            }
        }
    }
    
    func routeChanges(forChangeIDs changeIDs: [String]) -> [String] {
        var output = [String]()
        for changeID in changeIDs {
            if let routeChanges = routeChanges[changeID] {
                for changeString in routeChanges {
                    output.append(changeString)
                }
            }
        }
        return output
    }
}
