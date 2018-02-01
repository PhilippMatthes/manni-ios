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
        configureNavigationBar(forStop: State.shared.stop!)
        let lineName = State.shared.departure!.line
        let direction = State.shared.departure!.direction
        let stop = State.shared.stop!
        mapView.showLocations(lineName: lineName, direction: direction, stop: stop, log: {
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
    
    func configureNavigationBar(forStop stop: Stop) {
        navigationItem.titleLabel.text = stop.description
        navigationItem.titleLabel.textColor = UIColor.black
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(Icon.cm.arrowBack, for: .normal)
        backButton.tintColor = UIColor.black
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.setTitle(Config.backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(self.returnBack), for: .touchUpInside)
        
        let refreshButton = UIButton(type: .custom)
        refreshButton.setImage(Icon.cm.search, for: .normal)
        refreshButton.tintColor = UIColor.black
        refreshButton.setTitleColor(UIColor.black, for: .normal)
        refreshButton.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        
        positionButton.setImage(Icon.cm.clear, for: .normal)
        positionButton.tintColor = UIColor.black
        positionButton.setTitleColor(UIColor.black, for: .normal)
        positionButton.addTarget(self, action: #selector(self.locateUser), for: .touchUpInside)
        
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: refreshButton), UIBarButtonItem(customView: positionButton)], animated: true)
        navigationItem.hidesBackButton = false
    }
    
    @objc func returnBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh() {
        let lineName = State.shared.departure!.line
        let direction = State.shared.departure!.direction
        let stop = State.shared.stop!
        mapView.showLocations(lineName: lineName, direction: direction, stop: stop, zoomFit: false, log: {
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
