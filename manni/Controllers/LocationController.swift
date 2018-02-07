//
//  LocationController.swift
//  manni
//
//  Created by Philipp Matthes on 29.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Motion
import DVB
import MapKit
import BRYXBanner

class LocationController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var showUser: Bool = false
    var positionButton = UIButton(type: .custom)
    var locationManager = CLLocationManager()
    let locationAnnotation: MKPointAnnotation = MKPointAnnotation()
    var zoomOnNextLocationUpdate: Bool = true
    
    var banner = Banner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.isPitchEnabled = true;
        mapView.camera.pitch = Config.mapCameraPitch
        mapView.showsBuildings = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationBar(forStopName: State.shared.stopQuery!)
        let lineName = State.shared.departure!.line
        let direction = State.shared.departure!.direction
        let stopQuery = State.shared.stopQuery!
        mapView.showLocations(lineName: lineName, direction: direction, stopName: stopQuery, log: {
            logText, detailText in
            DispatchQueue.main.async {
                self.banner.dismiss()
                self.banner = Banner(title: logText, subtitle: detailText).designed()
                self.banner.show()
            }
        }) {
            self.mapView.addAnnotation(self.locationAnnotation)
        }
    }
    
    func configureNavigationBar(forStopName stopName: String) {
        navigationItem.configure(withText: stopName)
        navigationItem.add(.returnButton, .left) { self.returnBack() }
        navigationItem.add(.refreshButton, .right) { self.refresh() }
        navigationItem.add(.positionButton, .right) { self.locateUser() }
    }
    
    @objc func refresh() {
        let lineName = State.shared.departure!.line
        let direction = State.shared.departure!.direction
        let stopQuery = State.shared.stopQuery!
        mapView.showLocations(lineName: lineName, direction: direction, stopName: stopQuery, zoomFit: false, log: {
            logText, detailText in
            DispatchQueue.main.async {
                self.banner.dismiss()
                self.banner = Banner(title: logText, subtitle: detailText).designed()
                self.banner.show()
            }
        }) {
            self.mapView.addAnnotation(self.locationAnnotation)
        }
    }
    
    @objc func locateUser() {
        if showUser {
            locationManager.stopUpdatingLocation()
            showUser = false
            positionButton.tintColor = UIColor.black
            locationAnnotation.title = Config.lastKnownLocationTitle
        } else {
            zoomOnNextLocationUpdate = true
            locationManager.startUpdatingLocation()
            showUser = true
            positionButton.tintColor = UIColor.blue
        }
    }
    
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if showUser {
            let location = locations.last!
            
            locationAnnotation.coordinate = location.coordinate
            locationAnnotation.title = Config.currentLocationTitle

            mapView.addAnnotation(locationAnnotation)
            
            if zoomOnNextLocationUpdate {
                let diameter: Double = Config.zoomDiameter
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, diameter, diameter)
                mapView.setRegion(coordinateRegion, animated: true)
                zoomOnNextLocationUpdate = false
            }
        }
    }
}

extension LocationController: MKMapViewDelegate {    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            if let title = overlay.title {
                if let title = title {
                    if let etaDouble = Double(title) {
                        let eta = CGFloat(etaDouble)
                        let alpha = max(0.1, 1-(eta/10))
                        
                        circle.strokeColor = UIColor.red.withAlphaComponent(alpha)
                        circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: alpha)
                        circle.lineWidth = 1
                    }
                }
            }
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
}
