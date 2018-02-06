//
//  Prediction.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class Prediction {
    var probability: Double!
    
    init(probability: Double) {
        self.probability = probability
    }
}

class StopPrediction: Prediction {
    var stop: Stop!
    
    init(stop: Stop, probability: Double) {
        super.init(probability: probability)
        self.stop = stop
    }
}

class RoutePrediction: Prediction {
    var start: String!
    var end: String!
    
    init(start: String, end: String, probability: Double) {
        super.init(probability: probability)
        self.start = start
        self.end = end
    }
}
