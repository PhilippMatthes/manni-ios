//
//  RoutesController.swift
//  manni-ios
//
//  Created by It's free real estate on 29.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import DVB


class RoutesController: ViewController {
    
    public var endpoints: (Stop, Stop)? {
        didSet {
            overlayContainerController.overlayController.endpoints = endpoints
        }
    }
    
    private let backgroundController = RouteDetailController()
    private let overlayContainerController = RoutesOverlayContainerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Refactor this transient delegate
        overlayContainerController.routeSelectionDelegate = backgroundController
        
        backgroundController.view.backgroundColor = Color.blue.accent4
        addChild(backgroundController, in: view)
        addChild(overlayContainerController, in: view)
    }
    
}
