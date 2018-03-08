//
//  RouteController.swift
//  manni
//
//  Created by Philipp Matthes on 01.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import Motion
import DVB

struct ExpandedRoute {
    var route: Route!
    var expanded: Bool!
    
    init(route: Route, expanded: Bool) { self.route = route; self.expanded = expanded}
}

class RouteController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    var routes = [ExpandedRoute]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let from = State.shared.from, let to = State.shared.to {
            configureNavigationBar(from: from, to: to)
            loadRoute(from: from, to: to)
        } else {
            configureNavigationBar(from: "n/a", to: "n/a")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if let from = State.shared.from, let to = State.shared.to {
            loadRoute(from: from, to: to) {
                DispatchQueue.main.async{ refreshControl.endRefreshing() }
            }
        }
    }
    
}

extension RouteController {
    func loadRoute(from: String, to: String, completion: @escaping () -> Void = {}) {        
        Route.find(from: from, to: to) {
            result in
            if let response = result.success {
                self.routes = response.routes
                    .filter { !$0.partialRoutes.isEmpty }
                    .map { ExpandedRoute(route: $0, expanded: false) }
                DispatchQueue.main.async { self.tableView.reloadData() }
            } else {
                print("Response did not succeed")
            }
            completion()
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.canCancelContentTouches = false
        self.tableView.addSubview(self.refreshControl)
    }
    
    func configureNavigationBar(from: String, to: String) {
        let text = "\(Config.routesFrom) \(from) \(Config.to) \(to)"
        navigationItem.configure(withText: text)
        _ = navigationItem.add(.returnButton, .left) { self.returnBack() }
    }
}

extension RouteController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routes[indexPath.row].expanded = !routes[indexPath.row].expanded
        tableView.beginUpdates()
        tableView.endUpdates()
        if routes[indexPath.row].expanded {
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return routes[indexPath.row].expanded ? tableView.frame.height : RouteCell.closedHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RouteCell.identifier) as? RouteCell else {return UITableViewCell()}
        cell.configure(routes[indexPath.row].route, indexPath: indexPath, delegate: self)
        return cell
    }
}

extension RouteController: RouteCellDelegate {
    func scrollViewTapped(_ indexPath: IndexPath) {
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func showMapButtonPressed(route: Route) {
        performSegue(withIdentifier: "showRouteMap", sender: self)
    }
}





