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
import SwiftRater


class SearchController: UIViewController {
    
    enum SearchMode: String {
        case route
        case stop
    }
    
    @IBOutlet weak var modularSearchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var modularSearchBar: SearchBar!
    @IBOutlet weak var tableView: TableView!
    
    var currentlyEditingSearchBar: SearchBar?
    
    var switchButton: IconButton!
    var modularSearchButton: IconButton!
    var settingsButton: IconButton!
    
    var showsPredictions: Bool! = State.shared.predictionsActive == true
    var predictions: [Prediction] = [Prediction]()

    var query: String = Config.standardQuery
    var requestTimer: Timer?
    var stops: [StorableStop] = [StorableStop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if showsPredictions { loadPredictions() }
        configureSearchBar()
        configureTableViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectSearchBar(searchBar)
        if State.shared.predictionsActive != showsPredictions {
            showsPredictions = State.shared.predictionsActive
            if showsPredictions { loadPredictions() }
        }
        tableView.reloadData()
        SwiftRater.check()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension SearchController {
    func loadPredictions() {
        self.predictions = Predictor.loadPredictions()
    }
}

extension SearchController {    
    @objc func loadStops() {
        Stop.find(query) { result in
            guard let response = result.success else { return }
            self.stops = response.stops.map { StorableStop($0) }
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
        switch State.shared.searchMode {
        case .stop:
            searchBar.textField.text = text
        case .route:
            if let bar = currentlyEditingSearchBar {bar.textField.text = text}
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
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: StopCell.identifier, for: indexPath as IndexPath) as? StopCell {
                let stop = stops[indexPath.row]
                cell.setUp(forStop: stop.asStop())
                return cell
            }
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: StopCell.identifier, for: indexPath as IndexPath) as? StopCell {
            cell.setUp(forStopName: predictions[indexPath.row].query)
            return cell
        }
        return TableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? stops.count : predictions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return showsPredictions ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StopCell.height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? Config.searchResults : Config.suggestions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        
        let selectedStop = indexPath.section == 0 ? stops[indexPath.row].asStop() : nil
        if indexPath.section == 1 {
            replaceActiveSearchBarText(predictions[indexPath.row].query)
            switchSearchBar()
        }
        
        if let stop = selectedStop {
            replaceActiveSearchBarText(stop.description)
            switch State.shared.searchMode {
            case .stop:
                State.shared.addLogData(stop.name)
                break
            case .route:
                switchSearchBar()
                break
            }
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
        switchButton.add(for: .touchUpInside) {self.switchModularSearchBar(sender: self.switchButton)}
        
        modularSearchButton = IconButton(image: Icon.cm.search)
        modularSearchButton.add(for: .touchUpInside) {self.openRouteOrDeparturesController()}
        
        settingsButton = IconButton(image: Icon.cm.settings)
        settingsButton.add(for: .touchUpInside) {self.openSettingsController()}
        
        modularSearchBar.alpha = State.shared.searchMode == .route ? 1.0 : 0.0
        searchBar.leftViews = [switchButton]
        searchBar.rightViews = [settingsButton, modularSearchButton]
        searchBar.placeholder = Config.searchBarPlaceHolder
        modularSearchBar.placeholder = Config.modularSearchBarPlaceHolderDestination
        
        searchBar.contentEdgeInsets = UIEdgeInsetsMake(20,4,4,4)
        modularSearchBar.contentEdgeInsets = UIEdgeInsetsMake(4, 53, 4, 4)
        tableView.contentInset = UIEdgeInsetsMake(50,0,0,0)
        
        searchBar.textField.delegate = self
        modularSearchBar.textField.delegate = self
        
        searchBar.blur()
        modularSearchBar.blur()
        
        switch State.shared.searchMode {
        case .stop:
            closeModularSearchBar()
            searchBar.placeholder = Config.searchBarPlaceHolder
            break
        case .route:
            openModularSearchBar()
            searchBar.placeholder = Config.modularSearchBarPlaceHolderStart
            switchButton = IconButton(image: Icon.cm.close)
            break
        }
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
    
    func switchModularSearchBar(sender: UIButton!) {
        switch State.shared.searchMode {
        case .stop:
            searchBar.placeholder = Config.modularSearchBarPlaceHolderStart
            State.shared.searchMode = .route
            switchButton = IconButton(image: Icon.cm.close)
            openModularSearchBar()
            break
        case .route:
            State.shared.searchMode = .stop
            closeModularSearchBar()
            searchBar.placeholder = Config.searchBarPlaceHolder
            break
        }
    }
    
    func openRouteOrDeparturesController() {
        switch State.shared.searchMode {
        case .stop:
            if let fromText = searchBar.textField.text {
                if fromText != "" {
                    State.shared.stopQuery = fromText
                    performSegue(withIdentifier: "showDepartures", sender: self)
                }
            }
        case .route:
            if let fromText = searchBar.textField.text, let toText = modularSearchBar.textField.text {
                if fromText != "" && toText != "" {
                    State.shared.from = fromText
                    State.shared.to = toText
                    State.shared.addLogData(fromText, toText)
                    performSegue(withIdentifier: "showRoutes", sender: self)
                }
            }
        }
    }
    
    func openSettingsController() {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
}

extension SearchController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        openRouteOrDeparturesController()
        return true
    }
}
