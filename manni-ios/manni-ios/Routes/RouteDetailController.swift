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
    fileprivate let tableView = TableView()
    
    private var routeDetails = [RouteDetail]()
    
    override func viewDidLoad() {
        view.backgroundColor = Color.blue.accent4
        
        prepareTableView()
    }
}


extension RouteDetailController {
    fileprivate func prepareTableView() {
        view.layout(tableView)
            .edges()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        for routeDetailCellType in [
            RouteArrival.Cell.self,
            RouteDeparture.Cell.self,
            RouteKeyStop.Cell.self,
        ] {
            tableView.register(routeDetailCellType, forCellReuseIdentifier: routeDetailCellType.reuseIdentifier)
        }
        
    }
}


extension RouteDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let routeDetail = routeDetails[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: routeDetail.cellType.reuseIdentifier,
            for: indexPath
        ) as! RouteDetail.Cell
        cell.prepare(for: routeDetail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeDetails.count
    }
}

extension RouteDetailController: RouteSelectionDelegate {
    func didSelect(route: Route) {
        collectRouteDetails(for: route)
        tableView.reloadData()
    }
    
    fileprivate func collectRouteDetails(for route: Route) {
        // Descend the route details and extract all needed information
        for routePartial in route.partialRoutes {
            if routePartial.mode.mode == Mode.mobilityStairsUp {
                // It is necessary to go down stairs
                // TODO
            } else if routePartial.mode.mode == Mode.mobilityStairsDown {
                // It is necessary to go up stairs
                // TODO
            } else {
                // Regular transit
                if let regularStops = routePartial.regularStops, !regularStops.isEmpty {
                    for (i, routeStop) in regularStops.enumerated() {
                        if i == 0 {
                            routeDetails.append(RouteKeyStop(routeStop: routeStop))
                            routeDetails.append(RouteDeparture(departureTime: routeStop.departureTime))
                        } else if i < regularStops.endIndex - 1 {
                            // Passed by stops
                            // TODO
                        } else {
                            routeDetails.append(RouteArrival(arrivalTime: routeStop.arrivalTime))
                            routeDetails.append(RouteKeyStop(routeStop: routeStop))
                        }
                    }
                }
            }
        }
        print(routeDetails)
    }
}
