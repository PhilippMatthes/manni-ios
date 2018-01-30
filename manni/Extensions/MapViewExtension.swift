//
//  MapViewExtension.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit
import DVB
import BRYXBanner
import Material
import Motion

extension MKMapView {
    func zoomFitAnnotations(includeCurrentLocation include: Bool=true) {
        
        if !include {
            showAnnotations(annotations, animated: true)
        } else {
            var zoomRect = MKMapRectNull
            
            let point = MKMapPointForCoordinate(userLocation.coordinate)
            let pointRect = MKMapRectMake(point.x, point.y, 0, 0)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
            
            for annotation in annotations {
                
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect)
                }
            }
            
            setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(8, 8, 8, 8), animated: true)
        }
        
    }
    
    func showLocations(lineName: String,
                       direction: String,
                       stop: Stop,
                       etaRange: Int=Config.standardEtaRange,
                       zoomFit: Bool=true) {
        var banner = Banner(title: "Ortung für die Linie \(lineName) wird durchgeführt...").designed().showAssign(duration: Config.bannerDuration)
        Locator.locate(lineName: lineName, direction: direction, aroundStop: stop) {
            error, result in
            switch error {
            case .success:
                DispatchQueue.main.async {
                    banner.dismiss()
                    banner = Banner(title: "Erfolg! Daten zur Linie \(lineName) Richtung \(direction) konnten an \(result!.count) Orten gefunden werden.").designed().showAssign(duration: Config.bannerDuration)
                }
                let dispatchGroup = DispatchGroup()
                DispatchQueue.main.async {
                    self.removeAnnotations(self.annotations)
                    self.removeOverlays(self.overlays)
                }
                for (routeStop, departure) in Locator.filter(result!) {
                    dispatchGroup.enter()
                    if let c = routeStop.coordinate {
                        let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                        DispatchQueue.main.async {
                            self.addCircle(location: location, departure: departure)
                            if departure.ETA < etaRange {
                                self.addAnnotation(location: location, departure: departure)
                            }
                        }
                        dispatchGroup.leave()
                    } else {
                        Locator.location(forRouteStop: routeStop) {
                            success, location in
                            if success {
                                DispatchQueue.main.async {
                                    self.addCircle(location: location!, departure: departure)
                                    if departure.ETA < etaRange {
                                        self.addAnnotation(location: location!, departure: departure)
                                    }
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    if zoomFit{ self.zoomFitAnnotations(includeCurrentLocation: false) }
                }
            case .linesCouldNotBeLoaded:
                DispatchQueue.main.async {
                    banner.dismiss()
                    banner = Banner(title: "Linien konnten nicht geladen werden.").designed().showAssign(duration: Config.bannerDuration)
                }
            case .routeStopsCouldNotBeLoaded:
                DispatchQueue.main.async {
                    banner.dismiss()
                    banner = Banner(title: "Haltestellen konnten nicht geladen werden.").designed().showAssign(duration: Config.bannerDuration)
                }
            case .occurencesCouldNotBeLoaded:
                DispatchQueue.main.async {
                    banner.dismiss()
                    banner = Banner(title: "Die Zeittafeln der Haltestellen konnten nicht geladen werden.").designed().showAssign(duration: Config.bannerDuration)
                }
            case .failure:
                DispatchQueue.main.async {
                    banner.dismiss()
                    banner = Banner(title: "Es ist ein Fehler bei der Ortung aufgetreten.").designed().showAssign(duration: Config.bannerDuration)
                }
            }
        }
    }
    
    func addAnnotation(location: CLLocation, departure: Departure, radius: CLLocationDistance=100){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = departure.description
        circle.subtitle = String(departure.description)
        self.addAnnotation(circle)
    }
    
    func addCircle(location: CLLocation, departure: Departure, radius: CLLocationDistance=100){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = String(departure.ETA)
        circle.subtitle = String(departure.description)
        self.add(circle)
    }
}
