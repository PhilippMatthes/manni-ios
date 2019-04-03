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
import CoreLocation
import Intents

class DeparturesController: UIViewController {
    
    @IBOutlet weak var tableView: TableView!
    
    var previousViewController: UIViewController?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.add(for: .valueChanged) {self.handleRefresh(refreshControl: refreshControl)}
        return refreshControl
    }()
    
    var departures: [Departure] = [Departure]()
    var stop: Stop?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.blue.lighten5
        configureTableView()
        navigationItem.title = State.shared.stopQuery!
        refreshControl.refreshManually()
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
            self.stop = first
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
    
    override var prefersStatusBarHidden: Bool {
        return Device.runningOniPhoneX
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
        if #available(iOS 12.0, *) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: Config.showLocation, style: .default) {
                action in
                let locationController = UIStoryboard.instanciateController(withId: "LocationController") as! LocationController
                State.shared.departure = self.departures[indexPath.row]
                self.navigationController?.pushViewController(locationController, animated: true)
            })
            alertController.addAction(UIAlertAction(title: Config.addIntent, style: .default) {
                action in
                let intent = GetCurrentDeparturesOfLineAtStopIntent()
                guard let stop = self.stop else {return}
                intent.stop = stop.name
                let departure = self.departures[indexPath.row]
                intent.line = departure.line
                
                let interaction = INInteraction(intent: intent, response: nil)
                interaction.donate() {
                    error in
                    if let error = error {
                        let alertController = UIAlertController(title: "Aktion fehlgeschlagen.", message: error.localizedDescription, preferredStyle: .actionSheet)
                        alertController.addAction(UIAlertAction(title: Config.cancel, style: .cancel) {
                            action in
                        })
                        self.present(alertController, animated: true)
                    }
                }
            })
            alertController.addAction(UIAlertAction(title: Config.cancel, style: .cancel) {
                action in
            })
            self.present(alertController, animated: true)
        } else {
            let locationController = UIStoryboard.instanciateController(withId: "LocationController") as! LocationController
            State.shared.departure = self.departures[indexPath.row]
            self.navigationController?.pushViewController(locationController, animated: true)
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
    }
}




