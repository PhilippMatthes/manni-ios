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
    
    public var programmaticDismissDelegate: ProgrammaticDismissDelegate?
    
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    fileprivate let tableView = TableView()
    
    private var routeDetails = [RouteDetail]()
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        prepareTableView()
    }
    
    @objc func backButtonTouched() {
        dismiss(animated: true)
        programmaticDismissDelegate?.willDismissProgrammatically()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension RouteDetailController {
    fileprivate func prepareTableView() {
        view.layout(tableView)
            .edges()
        
        tableView.contentInset = .init(top: 128, left: 0, bottom: 128, right: 0)
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        
        for routeDetailCellType in [
            RouteByFoot.Cell.self,
            RouteTransit.Cell.self,
        ] {
            tableView.register(routeDetailCellType, forCellReuseIdentifier: routeDetailCellType.reuseIdentifier)
        }
        
        let tableViewBackground = SkeuomorphismView()
        tableViewBackground.gradient = Gradients.clouds
        tableView.insertSubview(tableViewBackground, at: 0)
        tableViewBackground.layer.zPosition = -1
        tableViewBackground.cornerRadius = 24
        tableViewBackground.clipsToBounds = true
        tableViewBackground.lightShadowOpacity = 0
        tableViewBackground.darkShadowOpacity = 0
        tableViewBackground.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewBackground.contentView.layout(backButton)
            .left(24)
            .top(24)
            .width(64)
            .height(64)
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        
        NSLayoutConstraint(item: tableViewBackground, attribute: .height, relatedBy: .equal, toItem: tableView, attribute: .height, multiplier: 1.0, constant: 64 + Screen.height).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: -96).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {        
        // Dismiss, if the user sufficiently pulls downwards
        // while having the scroll view at least scrolled to the top
        if velocity.y < -1 && scrollView.contentOffset.y < -scrollView.contentInset.top {
            dismiss(animated: true)
            programmaticDismissDelegate?.willDismissProgrammatically()
            return
        }
        
        // Dismiss, if the scroll view is pulled downwards sufficiently
        // and if the user did not scroll upwards
        if velocity.y <= 0 && scrollView.contentOffset.y < -scrollView.contentInset.top - 128 {
            dismiss(animated: true)
            programmaticDismissDelegate?.willDismissProgrammatically()
            return
        }
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
        
        if routeDetails.count != 1 {
            routeDetails.first?.position = .top
            routeDetails.last?.position = .bottom
        } else {
            routeDetails.first?.position = .both
        }
    }
}
