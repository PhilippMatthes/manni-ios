//
//  WKInterfaceMapExtension.swift
//  manni
//
//  Created by Philipp Matthes on 31/5/18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit

extension WKInterfaceMap {
    func zoomFit(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        setRegion(MKCoordinateRegion(center: coordinate, span: span))
    }
    
    func zoomFit(coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        setRegion(MKCoordinateRegion(center: coordinate, span: span))
    }
}
