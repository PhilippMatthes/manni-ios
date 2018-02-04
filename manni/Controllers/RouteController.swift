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
    
    var routes = [ExpandedRoute]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        
        if let from = State.shared.from, let to = State.shared.to {
            configureNavigationBar(from: from, to: to)
            loadRoute(from: from, to: to)
        } else {
            configureNavigationBar(from: "n/a", to: "n/a")
        }
    }
    
}

extension RouteController {
    func loadRoute(from: String, to: String) {        
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
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureNavigationBar(from: String, to: String) {
        navigationItem.titleLabel.text = "Routen von \(from) nach \(to)"
        navigationItem.titleLabel.textColor = UIColor.black
        let backButton = UIButton(type: .custom)
        backButton.setImage(Icon.cm.arrowBack, for: .normal)
        backButton.tintColor = UIColor.black
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.setTitle(Config.backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(self.returnBack), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
        navigationItem.hidesBackButton = false
    }
    
    @objc func returnBack() {
        self.dismiss(animated: true, completion: nil)
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
        cell.configure(routes[indexPath.row].route)
        return cell
    }
}





