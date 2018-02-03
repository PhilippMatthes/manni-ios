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

class RouteController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var routeSections = [RouteSection]()
    
    var selectedIndexPath: IndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndexPath = IndexPath(row: -1, section: -1)
        let nib = UINib(nibName: "ExpandableHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "expandableHeaderView")
        
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
                self.routeSections = response.routes.map { RouteSection(start: from, end: to, expanded: false, route: $0) }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return routeSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSections[section].route.partialRoutes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return routeSections[indexPath.section].expanded ? 200 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as? ExpandableHeaderView else {return nil}
        headerView.configure(routeSection: routeSections[section],
                             section: section,
                             delegate: self)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PartialRouteCell.identifier) as? PartialRouteCell else {return UITableViewCell()}
        cell.setUp(forPartialRoute: routeSections[indexPath.section].route.partialRoutes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        routeSections[indexPath.section].expanded = !routeSections[indexPath.section].expanded
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }
    
}

extension RouteController: ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        routeSections[section].expanded = !routeSections[section].expanded
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
    }
}





