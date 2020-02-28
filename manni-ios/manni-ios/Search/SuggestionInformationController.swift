//
//  SuggestionInformationController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 08.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import MapKit
import DVB

class SuggestionInformationController: ViewController {
    
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    fileprivate let titleLabel = UILabel()
    fileprivate let explanationLabel = UILabel()
    fileprivate let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("#ECE9E6")
        
        view.layout(backButton)
            .top(24)
            .left(24)
            .height(64)
            .width(64)
        backButton.pulseColor = Color.blue.base
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        
        view.layout(titleLabel)
            .below(backButton, 24)
            .left(24)
            .right(24)
        titleLabel.font = RobotoFont.bold(with: 24)
        titleLabel.textColor = Color.grey.darken4
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = "Wie funktioniert die Haltestellenvorhersage?"
        
        view.layout(explanationLabel)
            .below(titleLabel, 8)
            .left(24)
            .right(24)
        explanationLabel.font = RobotoFont.light(with: 18)
        explanationLabel.textColor = Color.grey.darken2
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.text = "Jedes Mal, wenn Du eine Haltestelle auswählst, " +
                                "speichert Dein Gerät dies lokal in einem Graphen ab. Du behältst " +
                                "also die volle Kontrolle über Deine Daten. " +
                                "Dein Graph sieht aktuell so aus:"
        
        view.layout(mapView)
            .below(explanationLabel, 16)
            .left()
            .right()
            .bottom()
        mapView.delegate = self
        mapView.layer.cornerRadius = 24
        
        prepareGraph()
    }
    
    @objc func backButtonTouched() {
        self.dismiss(animated: true)
    }
    
}

internal extension Stop {
    var coordinate: CLLocationCoordinate2D? {
        get {
            guard let location = location else {return nil}
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
    }
}


internal class RouteGraphPolyline: MKPolyline {
    var edge: Edge?
}


extension SuggestionInformationController: MKMapViewDelegate {
    fileprivate func prepareGraph() {
        // Focus on the important things
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        if #available(iOS 11.0, *) {
            mapView.mapType = .mutedStandard
        }
        
        var stops = Set<Stop>()
        
        for edge in RouteGraph.main.edges {
            
            stops.insert(edge.origin)
            stops.insert(edge.destination)
            
            guard
                let originCoordinate = edge.origin.coordinate,
                let destinationCoordinate = edge.destination.coordinate
            else {continue}
            
            let polyLine = RouteGraphPolyline(coordinates: [originCoordinate, destinationCoordinate], count: 2)
            polyLine.edge = edge
            mapView.addOverlay(polyLine)
        }
        
        for stop in stops {
            guard let coordinate = stop.coordinate else {continue}
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = stop.name
            annotation.subtitle = stop.region
            mapView.addAnnotation(annotation)
        }
        
        zoomForAllOverlays()
    }
    
    func zoomForAllOverlays() {
        guard let initial = mapView.overlays.first?.boundingMapRect else { return }

        let insets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        let mapRect = mapView.overlays
            .dropFirst()
            .reduce(initial) { $0.union($1.boundingMapRect) }

        mapView.setVisibleMapRect(mapRect, edgePadding: insets, animated: true)
    }
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? RouteGraphPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = Color.black.withAlphaComponent(0.75)
            polylineRenderer.lineWidth = CGFloat(min(polyline.edge?.weight ?? 1, 10))
            polylineRenderer.lineCap = .round
            polylineRenderer.lineJoin = .round
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
