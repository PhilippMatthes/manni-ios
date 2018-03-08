//
//  DeparturesController.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import UIKit
import DVB
import Material

class DeparturesController: UIViewController {
    
    @IBOutlet weak var tableView: TableView!
    
    var previousViewController: UIViewController?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.add(for: .valueChanged) {self.handleRefresh(refreshControl: refreshControl)}
        return refreshControl
    }()
    
    var departures: [Departure] = [Departure]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.blue.lighten5
        configureTableView()
        configureNavigationBar(withText: State.shared.stopQuery!)
        loadDepartures(forStopName: State.shared.stopQuery!) {}
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        if let stopQuery = State.shared.stopQuery {
            loadDepartures(forStopName: stopQuery) {
                refreshControl.endRefreshing()
            }
        }
    }
    
    func loadDepartures(forStopName stopName: String, completion: @escaping () -> Void) {
        Stop.find(stopName) {
            result in
            guard let result = result.success, let first = result.stops.first else {return}
            State.shared.stopId = first.id
            Departure.monitor(stopWithId: first.id) { result in
                guard let response = result.success else { return }
                self.departures = response.departures
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion()
                }
            }
        }
    }
    
    func configureNavigationBar(withText text: String) {
        navigationItem.configure(withText: text)
        _ = navigationItem.add(.returnButton, .left) { self.returnBack() }
    }
    
}

extension DeparturesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DepartureCell.identifier, for: indexPath as IndexPath) as! DepartureCell
        let departure = departures[indexPath.row]
        cell.setUp(forDeparture: departure)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departures.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Config.departuresTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        State.shared.departure = departures[indexPath.row]
        performSegue(withIdentifier: "showLocation", sender: self)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
    }
}




