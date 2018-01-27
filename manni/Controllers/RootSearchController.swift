//
//  RootSearchController.swift
//  manni
//
//  Created by Philipp Matthes on 26.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import Motion
import DVB


class RootSearchBarController: UIViewController {
    
    @IBOutlet weak var tableView: TableView!
    
    var query: String = "Hauptbahnhof"
    
    var requestTimer: Timer?

    var stops: [Stop] = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = Color.blue.lighten5
        loadStops()
        configureSearchBar()
        configureTableView()
    }
    
    func configureSearchBar() {
        guard let searchBar = searchBarController?.searchBar else { return }
        searchBar.delegate = self
    }
    
    @objc func loadStops() {
        Stop.find(query) { result in
            guard let response = result.success else { return }
            self.stops = response.stops
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension RootSearchBarController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        if let text = text {
            if let timer = requestTimer {
                timer.invalidate()
            }
            requestTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loadStops), userInfo: nil, repeats: false)
            query = text
        }
    }
}

extension RootSearchBarController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCell", for: indexPath as IndexPath) as! TableViewCell
        let stop = stops[indexPath.row]
        cell.setUp(forStop: stop)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        State.shared.stop = stops[indexPath.row]
        performSegue(withIdentifier: "showDepartures", sender: self)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}
