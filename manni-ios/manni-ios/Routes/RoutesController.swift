//
//  RoutesController.swift
//  manni-ios
//
//  Created by It's free real estate on 27.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import DVB


class RoutesController: ViewController {
    
    private let tableView = TableView()
    
    public func loadRoute(from origin: Stop, to destination: Stop) {
        Route.find(fromWithID: origin.id, toWithID: destination.id) {
            result in
            
        }
    }
    
}
