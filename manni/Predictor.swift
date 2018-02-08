//
//  Predictor.swift
//  manni
//
//  Created by Philipp Matthes on 08.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

enum ScoreType {
    case vertical
    case horizontal
}

class Predictor {
    
    static func loadPredictions(forDate date: Date = Date(), sort: Bool=true) -> [Prediction] {
        let logData: [String : [Date]] = State.shared.logData
        let predictions: [Prediction] = logData.keys
            .filter { logData[$0] != nil }
            .map { Prediction($0) }
        for prediction in predictions {
            let dates: [Date] = logData[prediction.query]!
            prediction.setScore(Predictor.score(.horizontal ,dates, date) + Predictor.score(.vertical, dates, date))
        }
        return sort ? predictions.sorted { $0.score > $1.score } : predictions
    }
    
    static func score(_ type: ScoreType, _ dates: [Date], _ referenceDate: Date) -> Double {
        var score: Double = 0
        for date in dates {
            let timeDifference: Double = Double(referenceDate.seconds(from: date))
            var timeDifferenceTruncated: Double
            switch type {
            case .vertical:
                timeDifferenceTruncated = timeDifference.truncatingRemainder(dividingBy: 604800)
            case .horizontal:
                timeDifferenceTruncated = timeDifference.truncatingRemainder(dividingBy: 86400)
            }
            if timeDifferenceTruncated.isZero {
                continue
            }
            score += 1/(pow(timeDifferenceTruncated, 2))
        }
        return score
    }
}
