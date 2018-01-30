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
    @IBOutlet weak var otvConstraint: NSLayoutConstraint!
    
    let cellHeight: CGFloat = CGFloat(50)
    
    var query: String = Config.standardQuery
    
    var otvIsOpen: Bool = true
    
    var requestTimer: Timer?

    var stops: [Stop] = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = Color.blue.lighten5
        configureSearchBar()
        configureTableViews()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension RootSearchBarController: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        if let text = text {
            if let timer = requestTimer {
                timer.invalidate()
            }
            requestTimer = Timer.scheduledTimer (
                timeInterval: Config.searchResultsLoadingInterval,
                target: self,
                selector: #selector(self.loadStops),
                userInfo: nil,
                repeats: false
            )
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
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        let stop = stops[indexPath.row]
        State.shared.stop = stop
        performSegue(withIdentifier: "showDepartures", sender: self)
    }
    
    func configureTableViews() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}
