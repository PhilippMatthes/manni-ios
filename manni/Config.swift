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
    static let searchResultsLoadingInterval: Double = 0.5
    static let mapCameraPitch: CGFloat = 45.0
    static let zoomDiameter: Double = 2000
    static let circleRadius: Double = 100
    static let dateFormat: String = "HH:mm:ss"
    static let standardEtaRange: Int = 2
    static let bannerDuration: Double = 10
    
    static let currentLocationTitle: String = NSLocalizedString("currentLocationTitle", comment: "")
    static let lastKnownLocationTitle: String = NSLocalizedString("lastKnownLocationTitle", comment: "")
    static let standardQuery: String = NSLocalizedString("standardQuery", comment: "")
    static let modularSearchBarPlaceHolderStart: String = NSLocalizedString("modularSearchBarPlaceHolderStart", comment: "")
    static let searchBarPlaceHolder: String = NSLocalizedString("searchBarPlaceHolder", comment: "")
    static let modularSearchBarPlaceHolderDestination: String = NSLocalizedString("modularSearchBarPlaceHolderDestination", comment: "")
    static let backButtonTitle: String = NSLocalizedString("backButtonTitle", comment: "")
    static let amplifiedTransport: String = NSLocalizedString("amplifiedTransport", comment: "")
    static let scheduledChange: String = NSLocalizedString("scheduledChange", comment: "")
    static let shortTermChange: String = NSLocalizedString("shortTermChange", comment: "")
    static let suggestions: String = NSLocalizedString("suggestions", comment: "")
    static let searchResults: String = NSLocalizedString("searchResults", comment: "")
    static let routesFrom: String = NSLocalizedString("routesFrom", comment: "")
    static let route: String = NSLocalizedString("route", comment: "")
    static let locating: String = NSLocalizedString("locating", comment: "")
    static let lineCouldNotBeFound: String = NSLocalizedString("lineCouldNotBeFound", comment: "")
    static let lineWasFound: String = NSLocalizedString("lineWasFound", comment: "")
    static let yourLineIsNowNear: String = NSLocalizedString("yourLineIsNowNear", comment: "")
    static let direction: String = NSLocalizedString("direction", comment: "")
    static let duration: String = NSLocalizedString("duration", comment: "")
    static let changes: String = NSLocalizedString("changes", comment: "")
    static let arrivingIn: String = NSLocalizedString("arrivingIn", comment: "")
    static let fromPlatform: String = NSLocalizedString("fromPlatform", comment: "")
    static let settings: String = NSLocalizedString("settings", comment: "")
    static let delay: String = NSLocalizedString("delay", comment: "")
    static let tooEarly: String = NSLocalizedString("tooEarly", comment: "")
    static let scheduledArrival: String = NSLocalizedString("scheduledArrival", comment: "")
    static let to: String = NSLocalizedString("to", comment: "")
    static let stairsUpNecessary: String = NSLocalizedString("stairsUpNecessary", comment: "")
    static let stairsDownNecessary: String = NSLocalizedString("stairsDownNecessary", comment: "")
    static let positionChangeNecessary: String = NSLocalizedString("positionChangeNecessary", comment: "")
    static let interchanges: String = NSLocalizedString("interchanges", comment: "")
    static let durationNotAvailable: String = NSLocalizedString("durationNotAvailable", comment: "")
    static let footpath: String = NSLocalizedString("footpath", comment: "")
    static let showRouteOnMap: String = NSLocalizedString("showRouteOnMap", comment: "")
    static let laterButtonText: String = NSLocalizedString("laterButtonText", comment: "")
    
    static let determiningPosition: String = NSLocalizedString("determiningPosition", comment: "")
    static let didNotFindAnyStations: String = NSLocalizedString("didNotFindAnyStations", comment: "")
    static let pleaseActivateLocationServices: String = NSLocalizedString("pleaseActivateLocationServices", comment: "")
    static let gpsPositionCouldNotBeAccessed: String = NSLocalizedString("gpsPositionCouldNotBeAccessed", comment: "")
    static let loadingLiveMonitor: String = NSLocalizedString("loadingLiveMonitor", comment: "")
    static let thereWasAProblemDownloading: String = NSLocalizedString("thereWasAProblemDownloading", comment: "")
    static let refresh: String = NSLocalizedString("refresh", comment: "")
    static let refreshing: String = NSLocalizedString("refreshing", comment: "")
}
