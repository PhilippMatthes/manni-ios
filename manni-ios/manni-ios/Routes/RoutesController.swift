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
            guard let endpoints = endpoints else {return}
            Route.find(fromWithID: endpoints.0.id, toWithID: endpoints.1.id) {
                result in
                guard let success = result.success else {return}
                self.overlayContainerController.overlayViewController.routes = success.routes
            }
        }
    }
    
    private var backgroundController = ViewController()
    private var overlayContainerController = RoutesOverlayContainerController(
        overlayViewController: RoutesOverlayController()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(backgroundController, in: view)
        addChild(overlayContainerController, in: view)
    }
    
}
