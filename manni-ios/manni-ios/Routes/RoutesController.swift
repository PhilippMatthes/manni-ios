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
                guard let success = result.success else {
                    DispatchQueue.main.async {
                        if #available(iOS 10.0, *) {
                            UINotificationFeedbackGenerator()
                                .notificationOccurred(.error)
                        }
                        let alert = UIAlertController(title: "VVO-Schnittstelle nicht erreichbar oder es wurden keine Routen gefunden.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) {
                            _ in
                            self.dismiss(animated: true)
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                if #available(iOS 10.0, *) {
                    UINotificationFeedbackGenerator()
                        .notificationOccurred(.success)
                }
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
        
        backgroundController.view.backgroundColor = Color.blue.accent4
        addChild(backgroundController, in: view)
        addChild(overlayContainerController, in: view)
    }
    
}
