//
//  IntExtension.swift
//  manni
//
//  Created by Philipp Matthes on 03.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

extension Int {
    func mod(_ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = self % n
        return r >= 0 ? r : r + n
    }
}
