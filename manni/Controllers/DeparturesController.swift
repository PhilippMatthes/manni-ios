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
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    var departures: [Departure] = [Departure]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.blue.lighten5
        configureTableView()
        configureNavigationBar(forStop: State.shared.stop!)
        loadDepartures(forStop: State.shared.stop!) {}
    }
    
    func configureNavigationBar(forStop stop: Stop) {
        navigationItem.titleLabel.text = stop.description
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

    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if let stop = State.shared.stop {
            loadDepartures(forStop: stop) {
                refreshControl.endRefreshing()
            }
        }
    }
    
    func loadDepartures(forStop stop: Stop, completion: @escaping () -> Void) {
        Departure.monitor(stopWithName: stop.description) { result in
            guard let response = result.success else { return }
            self.departures = response.departures
            DispatchQueue.main.async {
                self.tableView.reloadData()
                completion()
            }
        }
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




