//
//  Predictor.swift
//  manni
//
//  Created by Philipp Matthes on 08.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation



class Predictor {
    
    static func loadPredictions() -> [String]? {
        let logData: [String : [Date]] = State.shared.logData
        
        guard logData.values.count > 2 else {return nil
            
        }
        
        var locationToStrings = [(String, Date)]()
        for entry in logData {
            for date in entry.value {
                locationToStrings.append((entry.key, date))
            }
        }
        locationToStrings = locationToStrings.sorted(by: {$0.1 < $1.1})
        
        var transitions = [String: [String: Int]]()
        for i in 0..<locationToStrings.count {
            if i == locationToStrings.count - 1 {break}
            let locationToLocation = (locationToStrings[i].0, locationToStrings[i + 1].0)
            if let transition = transitions[locationToLocation.0] {
                if transition[locationToLocation.1] != nil {
                    transitions[locationToLocation.0]![locationToLocation.1]! += 1
                } else {
                    transitions[locationToLocation.0]![locationToLocation.1] = 1
                }
            } else {
                transitions[locationToLocation.0] = [locationToLocation.1: 1]
            }
        }
        
        var predictions = [String]()
        for location in locationToStrings {
            guard predictions.count < 20 else {
                return predictions
            }
            guard let transition = transitions[location.0] else {
                continue
            }
            let transitionPredictions = transition
                .sorted(by: {$0.1 > $1.1})
                .map({$0.key})
            predictions.append(contentsOf: transitionPredictions)
        }
        return nil
    }
}
