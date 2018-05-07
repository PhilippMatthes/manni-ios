//  MIT License
//
//  Copyright (c) 2018 Philipp Matthes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static func loadObject<T>(ofType type: T, withIdentifier identifier: String) -> T? {
//        State.shared.defaults.synchronize()
        if let decoded = UserDefaults.standard.object(forKey: identifier) as? NSData {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? T {
                return object
            }
        }
        return nil
    }
    
    static func save<T>(object: T, withIdentifier identifier: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey: identifier)
//        State.shared.defaults.synchronize()
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

