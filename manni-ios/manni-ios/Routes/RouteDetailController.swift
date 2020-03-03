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
    fileprivate let topView = SkeuomorphismView()
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    fileprivate let tableView = TableView()
    
    private var routeDetails = [RouteDetail]()
    
    override func viewDidLoad() {
        view.backgroundColor = Color.blue.accent4
        
        prepareTableView()
        prepareTopView()
        prepareBackButton()
    }
    
    @objc func backButtonTouched() {
        dismiss(animated: true)
    }
}


extension RouteDetailController {
    fileprivate func prepareTopView() {
        view.layout(topView)
            .top()
            .left()
            .right()
            .height(140)
        topView.gradient = Gradients.clouds
        topView.darkShadowOpacity = 0.03
        topView.lightShadowOpacity = 0.3
        topView.roundedCorners = .bottomLeft
        topView.cornerRadius = 24
    }
    
    fileprivate func prepareBackButton() {
        topView.contentView.layout(backButton)
            .topSafe(12)
            .left(24)
            .height(64)
            .width(64)
        backButton.skeuomorphismView.lightShadowOpacity = 0.3
        backButton.skeuomorphismView.darkShadowOpacity = 0.2
        backButton.pulseColor = Color.blue.base
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }
    
    fileprivate func prepareTableView() {
        view.layout(tableView)
            .edges()
        
        tableView.contentInset = .init(top: 140, left: 0, bottom: 128, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        for routeDetailCellType in [
            RouteByFoot.Cell.self,
            RouteTransit.Cell.self,
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
        routeDetails = []
        // Descend the route details and extract all needed information
        for routePartial in route.partialRoutes {
            if routePartial.mode.mode == Mode.mobilityStairsUp {
                routeDetails.append(RouteStairsUp())
            } else if routePartial.mode.mode == Mode.mobilityStairsDown {
                routeDetails.append(RouteStairsDown())
            } else if routePartial.mode.mode == Mode.footpath {
                routeDetails.append(RouteWalk(walkDuration: routePartial.duration))
            } else {
                if let regularStops = routePartial.regularStops, !regularStops.isEmpty {
                    routeDetails.append(RouteTransit(regularStops: regularStops, modeElement: routePartial.mode))
                }
            }
        }
        
        routeDetails.first?.position = .top
        routeDetails.last?.position = .bottom
    }
}
