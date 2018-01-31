//
//  Config.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreGraphics

class Config {
    static let departuresTableViewCellHeight: CGFloat = 100.0
    static let searchBarPlaceHolder: String = "Haltestelle suchen"
    static let standardQuery: String = "Hauptbahnhof"
    static let searchResultsLoadingInterval: Double = 0.5
    static let backButtonTitle: String = "Zurück"
    static let mapCameraPitch: CGFloat = 45.0
    static let lastKnownLocationTitle: String = "Letzter bekannter Standort"
    static let currentLocationTitle: String = "Aktueller Standort"
    static let zoomDiameter: Double = 2000
    static let circleRadius: Double = 100
    static let dateFormat: String = "HH:mm:ss"
    static let standardEtaRange: Int = 2
    static let bannerDuration: Double = 10
}
