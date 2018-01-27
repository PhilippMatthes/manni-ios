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
    
    var stop: Stop?
    
    private init() {}
    
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
