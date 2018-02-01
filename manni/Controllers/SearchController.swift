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


class SearchController: UIViewController {
    
    @IBOutlet weak var modularSearchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var modularSearchBar: SearchBar!
    @IBOutlet weak var tableView: TableView!
    
    var currentlyEditingSearchBar: SearchBar?
    
    var switchButton: IconButton!
    var modularSearchButton: IconButton!

    var query: String = Config.standardQuery
    var showsModularSearchBar: Bool = false
    var requestTimer: Timer?
    var stops: [Stop] = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        configureSearchBar()
        configureTableViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectSearchBar(searchBar)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension SearchController {    
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

extension SearchController: SearchBarDelegate {
    func switchSearchBar() {
        if let selectedBar = currentlyEditingSearchBar {
            if selectedBar == searchBar {
                selectSearchBar(modularSearchBar)
            } else {
                selectSearchBar(searchBar)
            }
        } else {
            selectSearchBar(searchBar)
        }
    }
    
    func selectSearchBar(_ searchBar : SearchBar) {
        searchBar.textField.becomeFirstResponder()
        currentlyEditingSearchBar = searchBar
    }
    
    func replaceActiveSearchBarText(_ text: String) {
        if let bar = currentlyEditingSearchBar {
            bar.textField.text = text
        }
    }
    
    @objc func searchBarDidSelect(_ textField: UITextField) {
        currentlyEditingSearchBar = searchBar
    }
    
    @objc func modularSearchBarDidSelect(_ textField: UITextField) {
        currentlyEditingSearchBar = modularSearchBar
    }
   
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

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StopCell.identifier, for: indexPath as IndexPath) as! StopCell
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
        return Config.stopsCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        let stop = stops[indexPath.row]
        State.shared.stop = stop
        if showsModularSearchBar {
            replaceActiveSearchBarText(stop.name)
            if let from = searchBar.textField.text, let to = modularSearchBar.textField.text {
                if from != "" && to != "" {
                    openRouteController()
                }
            }
            switchSearchBar()
        } else {
            performSegue(withIdentifier: "showDepartures", sender: self)
        }
    }
    
    func configureTableViews() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension SearchController {
    func configureSearchBar() {
        searchBar.delegate = self
        modularSearchBar.delegate = self
        
        searchBar.textField.addTarget(self, action: #selector(searchBarDidSelect(_:)), for: UIControlEvents.touchDown)
        modularSearchBar.textField.addTarget(self, action: #selector(modularSearchBarDidSelect(_:)), for: UIControlEvents.touchDown)
        
        statusBarController?.statusBarStyle = .lightContent
        
        switchButton = IconButton(image: Icon.cm.shuffle)
        switchButton.addTarget(self, action: #selector(switchModularSearchBar(sender:)), for: .touchUpInside)
        
        modularSearchButton = IconButton(image: Icon.cm.search)
        modularSearchButton.addTarget(self, action: #selector(openRouteController), for: .touchUpInside)
        
        modularSearchBar.alpha = showsModularSearchBar ? 1.0 : 0.0
        modularSearchBar.leftViews = [modularSearchButton]
        searchBar.leftViews = [switchButton]
        searchBar.placeholder = Config.searchBarPlaceHolder
        modularSearchBar.placeholder = Config.modularSearchBarPlaceHolderDestination
        
        searchBar.contentEdgeInsets = UIEdgeInsetsMake(20,4,4,4)
        tableView.contentInset = UIEdgeInsetsMake(50,0,0,0)
        
        searchBar.blur()
        modularSearchBar.blur()
    }
    
    func openModularSearchBar() {
        modularSearchBarHeight.constant = 50
        tableView.setContentOffset(CGPoint(x: 0, y: -120), animated: true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.tableView.contentInset = UIEdgeInsetsMake(100,0,0,0)
                self.modularSearchBar.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func closeModularSearchBar() {
        modularSearchBarHeight.constant = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.tableView.contentInset = UIEdgeInsetsMake(50,0,0,0)
                self.modularSearchBar.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func switchModularSearchBar(sender: UIButton!) {
        if showsModularSearchBar {
            showsModularSearchBar = false
            closeModularSearchBar()
            searchBar.placeholder = Config.searchBarPlaceHolder
        } else {
            searchBar.placeholder = Config.modularSearchBarPlaceHolderStart
            showsModularSearchBar = true
            switchButton = IconButton(image: Icon.cm.close)
            openModularSearchBar()
        }
    }
    
    @objc func openRouteController() {
        if let fromText = searchBar.textField.text, let toText = modularSearchBar.textField.text {
            if fromText != "" && toText != "" {
                State.shared.from = fromText
                State.shared.to = toText
                performSegue(withIdentifier: "showRoutes", sender: self)
            }
        }
    }
    
}
