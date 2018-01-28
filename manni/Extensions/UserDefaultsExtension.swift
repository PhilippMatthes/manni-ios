//
//  UserDefaultsExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB

enum ListStates {
    case wasUpdated
    case wasAdded
}

extension UserDefaults {
    
    static func loadObject<T>(ofType type: T, withIdentifier identifier: String) -> T? {
        State.shared.defaults.synchronize()
        if let decoded = State.shared.defaults.object(forKey: identifier) as? NSData {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? T {
                return object
            }
        }
        return nil
    }
    
    static func save<T>(object: T, withIdentifier identifier: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        State.shared.defaults.set(encodedData, forKey: identifier)
        State.shared.defaults.synchronize()
    }
    
    static func loadAndExtendList<T>(withObject object: T, andIdentifier identifier: String) {
        if var list = UserDefaults.loadObject(ofType: [T](), withIdentifier: identifier) {
            list.append(object)
            UserDefaults.save(object: list, withIdentifier: identifier)
        } else {
            UserDefaults.save(object: [object], withIdentifier: identifier)
        }
    }
    
}

