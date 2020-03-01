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
            overlayContainerController.overlayViewController.endpoints = endpoints
        }
    }
    
    private var backgroundController = ViewController()
    private var overlayContainerController = RoutesOverlayContainerController(
        overlayViewController: RoutesOverlayController()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundController.view.backgroundColor = Color.blue.accent4
        addChild(backgroundController, in: view)
        addChild(overlayContainerController, in: view)
    }
    
}
