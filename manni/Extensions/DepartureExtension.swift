//
//  DepartureExtension.swift
//  manni
//
//  Created by Philipp Matthes on 29.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

extension Departure {
    public static func monitorMultiple(stopsWithName names: [String],
                                       date: Date = Date(),
                                       dateType: DateType = .departure,
                                       allowedModes modes: [Mode] = Mode.all,
                                       allowShorttermChanges: Bool = true,
                                       session: URLSession = .shared,
                                       completion: @escaping ([Result<MonitorResponse>]) -> Void) {
        Stop.find(name, session: session) { result in
            switch result {
            case let .failure(error): completion(Result(failure: error))
            case let .success(response):
                guard let first = response.stops.first else { completion(Result(failure: DVBError.response)); return }
                Departure.monitor(stopWithId: first.id, date: date, dateType: dateType, allowedModes: modes, allowShorttermChanges: allowShorttermChanges, session: session, completion: completion)
            }
        }
    }
}
