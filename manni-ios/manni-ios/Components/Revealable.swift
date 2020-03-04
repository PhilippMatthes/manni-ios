//
//  Revealable.swift
//  manni-ios
//
//  Created by It's free real estate on 28.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation


protocol Revealable {    
    func prepareReveal()
    func reveal(reverse: Bool, completion: @escaping (() -> ()))
}
