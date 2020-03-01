//
//  AnimatableMapView.swift
//  manni-ios
//
//  Created by It's free real estate on 01.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit


protocol MKPolylineAnimationDelegate {
    func shouldDrawPolyline(between origin: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D)
}


class MKPolylineAnimation {
    
    public let route: [CLLocationCoordinate2D]
    public let duration: TimeInterval
    public let completion: (() -> ())?
    
    public var delegate: MKPolylineAnimationDelegate?
    
    private let numberOfSteps: Int
    private var currentStep: Int
    private let timeInterval: TimeInterval
    
    private var timer: Timer?
    
    init?(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> ())?) {
        guard !route.isEmpty, duration > 0 else {return nil}
        
        self.route = route
        self.duration = duration
        self.completion = completion
        
        // If n is the length of the location set, we make n - 1 steps,
        // because the last step connects the polyline to the final location.
        self.numberOfSteps = route.count - 1
        self.currentStep = 0
        self.timeInterval = duration / TimeInterval(self.numberOfSteps)
    }
    
    public func start() {
        self.timer = Timer.scheduledTimer(
            timeInterval: self.timeInterval,
            target: self,
            selector: #selector(callback),
            userInfo: nil,
            repeats: true
        )
    }
    
    public func stop() {
        self.timer?.invalidate()
    }
    
    @objc func callback() {
        guard currentStep < numberOfSteps else {
            self.timer?.invalidate()
            completion?()
            return
        }
        
        delegate?.shouldDrawPolyline(between: route[currentStep], and: route[currentStep + 1])
        
        currentStep += 1
    }
}


class AnimatableMapView: MKMapView {
    
    func animate(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> ())?) {
        guard let animation = MKPolylineAnimation(route: route, duration: duration, completion: completion) else {
            return
        }
        animation.delegate = self
        animation.start()
    }
    
    func fit(toRoutes routes: [[CLLocationCoordinate2D]], userLocation: CLLocationCoordinate2D? = nil, animated: Bool = true) {
        let edgePadding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        var zoomRect: MKMapRect = .null
        
        var coordinates = routes.flatMap {$0}
        if let userLocation = userLocation {
            coordinates.append(userLocation)
        }
        
        for coordinate in coordinates {
            let mapPoint = MKMapPoint(coordinate)
            let rect = MKMapRect(x: mapPoint.x, y: mapPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }

        setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: animated)
    }
    
}

extension AnimatableMapView: MKPolylineAnimationDelegate {
    func shouldDrawPolyline(between origin: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D) {
        let polyline = MKPolyline(coordinates: [origin, destination], count: 2)
        addOverlay(polyline)
    }
}
