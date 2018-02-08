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
    var score: Double! = 0.0
    var query: String!
    
    init(_ query: String) {
        self.query = query
    }
    
    func setScore(_ p: Double) {
        self.score = p
    }
}
