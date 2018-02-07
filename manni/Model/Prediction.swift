//
//  Prediction.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

struct Prediction {
    var probability: Double!
    var query: String!
    
    init(probability: Double, query: String) {
        self.probability = probability
        self.query = query
    }
}
