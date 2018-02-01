
//
//  StorableStop.swift
//  manni
//
//  Created by Philipp Matthes on 28.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

class StorableStop: NSObject, NSCoding {
    
    public var _description: String!
    public var _hashValue: Int!
    public var id: String!
    public var latitude: Double?
    public var longitude: Double?
    public var name: String!
    public var region: String?
    
    override init() {
        super.init()
    }
    
    init(_description: String,
         _hashValue: Int,
         id: String,
         latitude: Double?,
         longitude: Double?,
         name: String,
         region: String?) {
        super.init()
        self._description = _description
        self._hashValue = _hashValue
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.region = region
    }
    
    init(_ stop: Stop) {
        super.init()
        self._description = stop.description
        self._hashValue = stop.hashValue
        self.id = stop.id
        self.latitude = stop.location?.latitude
        self.longitude = stop.location?.longitude
        self.name = stop.name
        self.region = stop.region
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let _description = aDecoder.decodeObject(forKey: "_description") as? String,
            let _hashValue = aDecoder.decodeObject(forKey: "_hashValue") as? Int,
            let id = aDecoder.decodeObject(forKey: "id") as? String,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double?,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double?,
            let name = aDecoder.decodeObject(forKey: "name") as? String,
            let region = aDecoder.decodeObject(forKey: "region") as? String?
            else {
                return nil
        }
        self.init(_description: _description,
                  _hashValue: _hashValue,
                  id: id,
                  latitude: latitude,
                  longitude: longitude,
                  name: name,
                  region: region)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_description, forKey: "_description")
        aCoder.encode(_hashValue, forKey: "_hashValue")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(region, forKey: "region")
    }
    
}


