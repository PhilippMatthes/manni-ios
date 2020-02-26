//
//  StopItemProvider.swift
//  manni-ios
//
//  Created by It's free real estate on 26.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import DVB


class StopItem: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    let stop: Stop
    
    init(stop: Stop) {
        self.stop = stop
    }
    
    private enum CodingKeys: String, CodingKey {
        case stopId
        case stopName
        case stopRegion
        case stopLocation
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let stopId = try values.decode(String.self, forKey: .stopId)
        let stopName = try values.decode(String.self, forKey: .stopName)
        let stopRegion = try values.decode(String?.self, forKey: .stopRegion)
        let stopLocation = try values.decode(WGSCoordinate?.self, forKey: .stopLocation)
        stop = Stop(id: stopId, name: stopName, region: stopRegion, location: stopLocation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stop.id, forKey: .stopId)
        try container.encode(stop.name, forKey: .stopName)
        try container.encode(stop.region, forKey: .stopRegion)
        try container.encode(stop.location, forKey: .stopLocation)
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return try JSONDecoder().decode(StopItem.self, from: data) as! Self
    }
    
}
