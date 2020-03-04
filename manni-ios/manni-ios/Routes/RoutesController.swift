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
    
    public var programmaticDismissDelegate: ProgrammaticDismissDelegate? {
        didSet {
            backgroundController.programmaticDismissDelegate = programmaticDismissDelegate
        }
    }
    
    private let nodgeView = UIView()
    private let backgroundController = RouteDetailController()
    private let overlayContainerController = RoutesOverlayContainerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Refactor this transient delegate
        overlayContainerController.routeSelectionDelegate = backgroundController
        
        addChild(backgroundController, in: view)
        addChild(overlayContainerController, in: view)
        
        view.backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            if let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top, topInset > 0 {
                // iPhone X
                let frame = CGRect(x: 0, y: 0, width: Screen.width, height: topInset)
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor.black.withAlphaComponent(0.5).cgColor,
                    UIColor.clear.cgColor
                ]
                gradientLayer.startPoint = .init(x: 0, y: 0)
                gradientLayer.endPoint = .init(x: 0, y: 1)
                gradientLayer.frame = frame
                nodgeView.layer.addSublayer(gradientLayer)
                nodgeView.frame = frame
                nodgeView.alpha = 0
                view.addSubview(nodgeView)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.nodgeView.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nodgeView.alpha = 0
    }
}
