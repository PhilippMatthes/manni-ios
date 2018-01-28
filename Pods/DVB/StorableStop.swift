//
//  StorableStop.swift
//
//  Created by Philipp Matthes on 28.01.18.
//

import Foundation

class StorableStop: NSObject, NSCoding {
    
    
    var entry: PollutionDataEntry?
    
    override init() {
        super.init()
    }
    
    init(stop: Stop) {
        super.init()
        self.coord = coord
        self._title = title
        self._subtitle = subtitle
        self.entry = entry
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let _title = aDecoder.decodeObject(forKey: "_title") as? String,
            let _subtitle = aDecoder.decodeObject(forKey: "_subtitle") as? String
            else {
                return nil
        }
        if let entry = UserDefaults.loadObject(ofType: PollutionDataEntry(), withIdentifier: "entry") {
            let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.init(coord: coord,
                      title: _title,
                      subtitle: _subtitle,
                      entry: entry)
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(coord.latitude, forKey: "latitude")
        aCoder.encode(coord.longitude, forKey: "longitude")
        aCoder.encode(_title, forKey: "_title")
        aCoder.encode(_subtitle, forKey: "_subtitle")
        aCoder.encode(entry, forKey: "entry")
    }
    
    var title: String? {
        get {
            return _title
        }
        set (value) {
            self._title = value!
        }
    }
    
    var subtitle: String? {
        get {
            return _subtitle
        }
        set (value) {
            self._subtitle = value!
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
    
}
