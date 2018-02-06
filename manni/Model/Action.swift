//
//  Action.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class Action: NSObject, NSCoding {
    
    
    required override init() {super.init()}
    
    convenience required init?(coder aDecoder: NSCoder) { self.init() }
    
    func encode(with aCoder: NSCoder) {}
    
    func asPrediction(withProbability probability: Double) -> Prediction {return Prediction(probability: probability)}
}

//extension Action: NSCopying {
//    func copy(with zone: NSZone? = nil) -> Any {
//        return Swift.type(of:self).init()
//    }
//}

class RouteAction: Action {
    var start: String!
    var end: String!
    
    required init() {
        super.init()
    }
    
    init(start: String, end: String) {
        super.init()
        self.start = start
        self.end = end
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let start = aDecoder.decodeObject(forKey: "start") as? String,
            let end = aDecoder.decodeObject(forKey: "end") as? String
            else {
                return nil
        }
        self.init(start: start, end: end)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(start, forKey: "start")
        aCoder.encode(end, forKey: "end")
    }
    
    override func asPrediction(withProbability probability: Double) -> Prediction {
        return RoutePrediction(start: start, end: end, probability: probability)
    }
}

class StopAction: Action {
    var stop: StorableStop!
    
    required init() {
        super.init()
    }
    
    init(stop: StorableStop) {
        super.init()
        self.stop = stop
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let stop = aDecoder.decodeObject(forKey: "stop") as? StorableStop
            else {
                return nil
        }
        self.init(stop: stop)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(stop, forKey: "stop")
    }
    
    override func asPrediction(withProbability probability: Double) -> Prediction {
        return StopPrediction(stop: stop.asStop(), probability: probability)
    }
}
