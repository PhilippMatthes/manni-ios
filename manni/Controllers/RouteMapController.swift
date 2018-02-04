//
//  RouteMapControlle.swift
//  manni
//
//  Created by Philipp Matthes on 04.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material
import Motion
import MapKit

class RouteMapController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
        configureNavigationBar()
        showRoute(State.shared.route!)
    }
    
    func configureNavigationBar() {
        navigationItem.titleLabel.text = "Route"
        navigationItem.titleLabel.textColor = UIColor.black
        let backButton = UIButton(type: .custom)
        backButton.setImage(Icon.cm.arrowBack, for: .normal)
        backButton.tintColor = UIColor.black
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.setTitle(Config.backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(self.returnBack), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
        navigationItem.hidesBackButton = false
    }
    
    func showRoute(_ route: Route, zoomFit: Bool=true) {
        mapView.removeOverlays(mapView.overlays)
        let partialRouteCoordinates = route.mapData.map { $0.points }
        let partialRouteStops = route.partialRoutes
            .flatMap { $0.regularStops }
            .flatMap { $0 }
            .filter { $0.coordinate != nil }
        
        let stopCoordinates = partialRouteStops
            .map { CLLocationCoordinate2D(latitude: $0.coordinate!.latitude, longitude: $0.coordinate!.longitude) }
        let stopNames = partialRouteStops
            .map { $0.name }
        
        for (c, n) in zip(stopCoordinates, stopNames) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = c
            annotation.title = n
            mapView.addAnnotation(annotation)
        }
        
        
        for i in 0..<partialRouteCoordinates.count {
            let route = partialRouteCoordinates[i]
            let coordinates = route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            polyline.title = "\(i)"
            mapView.add(polyline, level: .aboveRoads)
        }
        if zoomFit { mapView.zoomFitOverlays() }
    }
}

extension RouteMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = Colors.color(forInt: Int(overlay.title!!)!)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else {
            return MKCircleRenderer(overlay: overlay)
        }
    }
}
