//
//  RoutesController.swift
//  manni-ios
//
//  Created by It's free real estate on 27.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import DVB


class RoutesController: ViewController {
    
    public var endpoints: (Stop, Stop)? {
        didSet {
            guard let endpoints = endpoints else {return}
            Route.find(fromWithID: endpoints.0.id, toWithID: endpoints.1.id) {
                result in
                guard let success = result.success else {return}
                self.routes = success.routes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    fileprivate let tableView = TableView()
    
    private var routes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
}

extension RoutesController {
    fileprivate func prepareTableView() {
        view.layout(tableView)
            .top()
            .left()
            .right()
            .height(512)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RouteOverViewCell.self, forCellReuseIdentifier: RouteOverViewCell.reuseIdentifier)
    }
}

extension RoutesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RouteOverViewCell.reuseIdentifier, for: indexPath) as! RouteOverViewCell
        cell.route = routes[indexPath.row]
        return cell
    }
}
