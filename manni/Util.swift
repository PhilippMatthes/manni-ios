//
//  Util.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

class Util {
    static func permutations<T: Equatable>(_ array: Array<T>,k: Int) -> Array<Array<T>> {
        var array = array
        if k == 0 {
            return [[]]
        }
        
        if array.isEmpty {
            return []
        }
        
        let head = [array[0]]
        let subcombos = permutations(array, k: k - 1)
        var ret = subcombos.map {head + $0}
        array.remove(at: 0)
        ret += permutations(array, k: k)
        
        return ret
    }
    
    static func removeDupes<T: Equatable>(_ permutations: Array<Array<T>>) -> Array<Array<T>> {
        var output = [[T]]()
        for permutation in permutations {
            var duplicate = false
            for element in permutation {
                let filtered = permutation.filter { (e) -> Bool in
                    return e == element
                }
                if filtered.count > 1 {
                    duplicate = true
                }
            }
            if !duplicate {
                output.append(permutation)
            }
        }
        return output
    }
}
