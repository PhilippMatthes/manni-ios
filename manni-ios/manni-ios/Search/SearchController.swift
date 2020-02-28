//
//  SearchController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation
import Material
import Motion
import DVB
import AVFoundation
import FontAwesome_swift


class SearchController: ViewController {
    fileprivate var gpsFetchWasTriggered: Bool? {
        didSet {
            if gpsFetchWasTriggered == true {
                gpsView.startAnimating()
                UIView.animate(withDuration: 1.0) {
                    self.tableView.contentInset = .init(top: self.gpsViewExpandedHeight, left: 0, bottom: 256, right: 0)
                }
            } else if gpsFetchWasTriggered == false {
                gpsView.stopAnimating()
                UIView.animate(withDuration: 1.0) {
                    self.tableView.contentInset = .init(top: self.gpsViewCollapsedHeight, left: 0, bottom: 256, right: 0)
                }
            }
        }
    }
    fileprivate var gpsViewExpandedHeight: CGFloat = 168
    fileprivate let gpsViewCollapsedHeight: CGFloat = 64
    
    fileprivate var showsGreeting: Bool? {
        didSet {
            if showsGreeting == true {
                UIView.animate(withDuration: 1.0) {
                    self.greetingLabel.alpha = 1.0
                }
            } else if showsGreeting == false {
                UIView.animate(withDuration: 1.0) {
                    self.greetingLabel.alpha = 0.0
                }
            }
        }
    }
    
    fileprivate var showsTutorial: Bool? {
        didSet {
            if showsTutorial == true {
                UIView.animate(withDuration: 1.0) {
                    self.tutorialLabel.alpha = 1.0
                }
            } else if showsTutorial == false {
                UIView.animate(withDuration: 1.0) {
                    self.tutorialLabel.alpha = 0.0
                }
            }
        }
    }
    
    fileprivate let gpsView = GPSView()
    fileprivate let searchView = SearchView()
    fileprivate let greetingLabel = UILabel()
    fileprivate let tutorialLabel = UILabel()
    fileprivate let tableView = TableView(frame: .zero, style: .grouped)
    
    fileprivate var routeGraph = RouteGraph.main
    fileprivate var locationManager = CLLocationManager()
    fileprivate var fetchedStops = [Stop]()
    fileprivate var suggestedStops = [Stop]()
    fileprivate var query: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareGreeting()
        prepareTutorial()
        prepareTableView()
        prepareGPSView()
        prepareSearchView()
        prepareLocationManager()
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    @objc func viewWillEnterForeground() {
        suggestedStops = routeGraph.getStopSuggestions()
        
        if suggestedStops.count == 0 && fetchedStops.count == 0 {
            showsTutorial = true
            showsGreeting = true
        } else {
            UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillEnterForeground()
        
        AppDelegate.viewTapDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        searchView.reveal {
            self.gpsView.reveal {
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.viewTapDelegate = nil
        
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension SearchController {
    
    fileprivate func prepareGreeting() {
        view.layout(greetingLabel)
            .left(48)
            .right(48)
            .top(128)
        greetingLabel.alpha = 0.0
        greetingLabel.textColor = UIColor("#0652DD")
        greetingLabel.font = RobotoFont.bold(with: 48)
        greetingLabel.numberOfLines = 0
        greetingLabel.text = [
            "Hi!",
            "Hallöle!",
            "Glück auf!",
            "Moin moin!",
            "Hallo!",
            "Guten Tag!",
        ].randomElement()!
    }
    
    fileprivate func prepareTutorial() {
        view.layout(tutorialLabel)
            .left(48)
            .right(48)
            .below(greetingLabel, 8)
        tutorialLabel.alpha = 0.0
        tutorialLabel.textColor = Color.grey.darken4
        tutorialLabel.font = RobotoFont.light(with: 24)
        tutorialLabel.numberOfLines = 0
        let choice = [
            "Gute Fahrt!",
            "Auf gehts!",
            "Und los!",
            "Fahrkarte nicht vergessen!"
        ].randomElement()!
        tutorialLabel.text = "Du kannst nach unten wischen, um Haltestellen in Deiner Nähe zu finden. Alternativ gibt es unten eine Suchleiste. \(choice)"
    }
    
    fileprivate func prepareTableView() {
        view.layout(tableView)
            .edges(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(
            StopTableViewCell.self,
            forCellReuseIdentifier: StopTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: gpsViewCollapsedHeight, left: 0, bottom: 256, right: 0)
        tableView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }
        
        let tableViewBackground = UIView()
        tableView.insertSubview(tableViewBackground, at: 0)
        tableViewBackground.layer.zPosition = -1
        tableViewBackground.layer.cornerRadius = 24
        tableViewBackground.translatesAutoresizingMaskIntoConstraints = false
        tableViewBackground.isUserInteractionEnabled = false
        view.backgroundColor = Color.grey.lighten2
        tableViewBackground.backgroundColor = view.backgroundColor
        
        NSLayoutConstraint(item: tableViewBackground, attribute: .height, relatedBy: .equal, toItem: tableView, attribute: .height, multiplier: 1.0, constant: 64).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: -32).isActive = true
        NSLayoutConstraint(item: tableViewBackground, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    fileprivate func prepareGPSView() {
        tableView.insertSubview(gpsView, at: 0)
        gpsView.translatesAutoresizingMaskIntoConstraints = false
        gpsView.layer.zPosition = -2
        gpsView.cornerRadius = 0
        gpsView.prepareReveal()
        
        NSLayoutConstraint(item: gpsView, attribute: .height, relatedBy: .equal, toItem: tableView, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    fileprivate func prepareSearchView() {
        view.layout(searchView)
            .bottomSafe()
            .left(12)
            .right(12)
        searchView.delegate = self
        searchView.prepareReveal()
    }
    
    fileprivate func prepareLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
}

@available(iOS 11.0, *)
extension SearchController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let stop = indexPath.section == 0 ? fetchedStops[indexPath.row] : suggestedStops[indexPath.row]
        let itemProvider = NSItemProvider(object: StopItem(stop: stop))
        return [UIDragItem(itemProvider: itemProvider)]
    }
}

extension SearchController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        viewWillEnterForeground()
    }
}

extension SearchController: ViewTapDelegate {
    func viewWasTapped() {
        if (showsTutorial == true) {
            showsTutorial = false
        }
        if (showsGreeting == true) {
            showsGreeting = false
        }
    }
}

extension SearchController: SearchViewDelegate {
    func search(routeFrom departureStop: Stop, to destinationStop: Stop) {
        let controller = RoutesController()
        controller.endpoints = (departureStop, destinationStop)
        controller.presentationController?.delegate = self
        present(controller, animated: true)
    }
    
    func search(query: String) {
        if let oldQuery = self.query, query == oldQuery, fetchedStops.count != 0 {
            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            return
        }
        
        self.query = query
        
        Stop.find(query) {
            result in
            guard let success = result.success else {
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UINotificationFeedbackGenerator()
                            .notificationOccurred(.error)
                    }
                    let alert = UIAlertController(title: "VVO-Schnittstelle nicht erreichbar.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.fetchedStops = success.stops
            if let location = self.locationManager.location {
                self.fetchedStops.sort {$0.distance(from: location) ?? 0 < $1.distance(from: location) ?? 0}
            }
            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            DispatchQueue.main.async {
                UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
            }
        }
    }
}

extension SearchController {
    @objc func keyboardWillShow(notification:NSNotification){
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {return}
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = -keyboardFrame.bounds.maxY + 16
        }
    }

    @objc func keyboardWillHide(notification:NSNotification){
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = 0
        }
    }
}

extension SearchController: CLLocationManagerDelegate {
    static let didUpdateLocation = Notification.Name("didUpdateLocation")
    
    fileprivate func requestLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            locationManager.requestWhenInUseAuthorization()
            gpsFetchWasTriggered = false
            return
        }
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            locationManager.requestLocation()
            return
        }
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        let alert = UIAlertController(title: "GPS-Ortung nicht erlaubt.", message: "Du kannst die GPS-Ortung in den Einstellungen erlauben.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        
        gpsFetchWasTriggered = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        let alert = UIAlertController(title: "Es gab einen Fehler bei der GPS-Ortung.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        
        gpsFetchWasTriggered = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = manager.location else {return}
        self.gpsFetchWasTriggered = false
        
        Stop.findNear(coord: currentLocation.coordinate) {
            result in
            guard let success = result.success else {
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UINotificationFeedbackGenerator()
                            .notificationOccurred(.error)
                    }
                    let alert = UIAlertController(title: "VVO-Schnittstelle nicht erreichbar.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            self.fetchedStops = success.stops
            if let location = self.locationManager.location {
                self.fetchedStops.sort {$0.distance(from: location) ?? 0 < $1.distance(from: location) ?? 0}
            }
            DispatchQueue.main.async {
                UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
            }
        }
        NotificationCenter.default.post(name: SearchController.didUpdateLocation, object: nil, userInfo: ["location": currentLocation])
    }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? fetchedStops.count : suggestedStops.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StopTableViewCell.reuseIdentifier, for: indexPath
        ) as! StopTableViewCell
        let stop = indexPath.section == 0 ? fetchedStops[indexPath.row] : suggestedStops[indexPath.row]
        if cell.stop != stop {
            cell.stop = stop
        }
        if let location = locationManager.location {
            cell.location = location
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = indexPath.section == 0 ? fetchedStops[indexPath.row] : suggestedStops[indexPath.row]
        
        routeGraph.visit(stop: stop)
        DispatchQueue.global(qos: .background).async {
            RouteGraph.main = self.routeGraph
        }
        
        let controller = DeparturesController()
        controller.stop = stop
        controller.presentationController?.delegate = self
        if let location = locationManager.location {
            controller.location = location
        }
        present(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.opacity = 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            cell.layer.opacity = 1.0
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 && fetchedStops.count != 0 || section == 1 && suggestedStops.count != 0 else {return UIView()}
        let view = UIView()
        if section == 0 {
            let label = UILabel()
            label.text = "Suchergebnisse"
            label.font = RobotoFont.light(with: 24)
            view.layout(label).edges(top: 8, left: 16, bottom: 8, right: 16)
        } else {
            let label = UILabel()
            label.text = "Vorschläge"
            label.font = RobotoFont.light(with: 24)
            view.layout(label).edges(top: 8, left: 16, bottom: 8, right: 48)
            
            let suggestionBadgeButton = SkeuomorphismIconButton(image: UIImage.fontAwesomeIcon(
                name: .info, style: .solid, textColor: Color.grey.base, size: .init(width: 18, height: 18)
            ))
            
            view.layout(suggestionBadgeButton)
                .right(16)
                .centerY()
                .height(32)
                .width(32)
            suggestionBadgeButton.skeuomorphismView.cornerRadius = 16
            suggestionBadgeButton.addTarget(self, action: #selector(didSelectSuggestionInfoButton), for: .touchUpInside)
        }
        return view
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -gpsViewExpandedHeight - gpsViewCollapsedHeight && (
            gpsFetchWasTriggered == false || gpsFetchWasTriggered == nil
        ) {
            gpsFetchWasTriggered = true
            requestLocation()
        }
    }
}

extension SearchController {
    @objc func didSelectSuggestionInfoButton() {
        let controller = SuggestionInformationController()
        present(controller, animated: true)
    }
}
