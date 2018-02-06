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
    var settingsButton: IconButton!
    
    var showsPredictions: Bool! = State.shared.predictionsActive == true
    var predictions: [Prediction] = [Prediction]()

    var query: String = Config.standardQuery
    var requestTimer: Timer?
    var stops: [StorableStop] = [StorableStop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
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
            tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension SearchController {
    func loadPredictions() {
        self.predictions = State.shared.logData.keys.map { $0.asPrediction(withProbability: 1.0) }
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
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: StopCell.identifier, for: indexPath as IndexPath) as? StopCell {
                let stop = stops[indexPath.row]
                cell.setUp(forStop: stop.asStop())
                return cell
            }
        } else if let routePrediction = predictions[indexPath.row] as? RoutePrediction, let cell = tableView.dequeueReusableCell(withIdentifier: RoutePredictionCell.identifier, for: indexPath as IndexPath) as? RoutePredictionCell {
                cell.setUp(forStart: routePrediction.start, end: routePrediction.end)
                return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: StopCell.identifier, for: indexPath as IndexPath) as? StopCell, let stopPrediction = predictions[indexPath.row] as? StopPrediction {
                cell.setUp(forStop: stopPrediction.stop)
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
        if indexPath.section == 0 { return StopCell.height }
        else {
            return predictions[indexPath.row] is RoutePrediction ? RoutePredictionCell.height : StopCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Suchergebnisse" : "Vorschläge"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        
        var selectedStop = indexPath.section == 0 ? stops[indexPath.row].asStop() : nil
        if indexPath.section == 1, let stopPrediction = predictions[indexPath.row] as? StopPrediction { selectedStop = stopPrediction.stop }
        
        if let stop = selectedStop {
            State.shared.stop = stop
            switch State.shared.searchMode {
            case .stop:
                State.shared.addLogData(StopAction(stop: StorableStop(stop)))
                performSegue(withIdentifier: "showDepartures", sender: self)
                break
            case .route:
                replaceActiveSearchBarText(stop.name)
                openRouteControllerIfPossible()
                switchSearchBar()
                break
            }
        } else if let routePrediction = predictions[indexPath.row] as? RoutePrediction {
            searchBar.textField.text = routePrediction.start
            modularSearchBar.textField.text = routePrediction.end
            openRouteControllerIfPossible()
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
        modularSearchButton.addTarget(self, action: #selector(openRouteControllerIfPossible), for: .touchUpInside)
        
        settingsButton = IconButton(image: Icon.cm.settings)
        settingsButton.addTarget(self, action: #selector(openSettingsController), for: .touchUpInside)
        
        modularSearchBar.alpha = State.shared.searchMode == .route ? 1.0 : 0.0
        modularSearchBar.rightViews = [modularSearchButton]
        searchBar.leftViews = [switchButton]
        searchBar.rightViews = [settingsButton]
        searchBar.placeholder = Config.searchBarPlaceHolder
        modularSearchBar.placeholder = Config.modularSearchBarPlaceHolderDestination
        
        searchBar.contentEdgeInsets = UIEdgeInsetsMake(20,4,4,4)
        modularSearchBar.contentEdgeInsets = UIEdgeInsetsMake(4, 53, 4, 4)
        tableView.contentInset = UIEdgeInsetsMake(50,0,0,0)
        
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
    
    @objc func switchModularSearchBar(sender: UIButton!) {
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
    
    @objc func openRouteControllerIfPossible() {
        if let fromText = searchBar.textField.text, let toText = modularSearchBar.textField.text {
            if fromText != "" && toText != "" {
                State.shared.from = fromText
                State.shared.to = toText
                State.shared.addLogData(RouteAction(start: fromText, end: toText))
                performSegue(withIdentifier: "showRoutes", sender: self)
            }
        }
    }
    
    @objc func openSettingsController() {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
}
