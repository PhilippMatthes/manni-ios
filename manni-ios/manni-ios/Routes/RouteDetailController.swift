//
//  RouteDetailController.swift
//  manni-ios
//
//  Created by It's free real estate on 01.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material
import MapKit


class RouteDetailController: ViewController {
    
    override func viewDidLoad() {
        view.backgroundColor = Color.blue.accent4
    }
    
}


extension RouteDetailController {

}

extension RouteDetailController: RouteSelectionDelegate {
    func didSelect(route: Route) {
        print(route)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = Color.black.withAlphaComponent(0.75)
            polylineRenderer.lineWidth = 1
            polylineRenderer.lineCap = .round
            polylineRenderer.lineJoin = .round
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
