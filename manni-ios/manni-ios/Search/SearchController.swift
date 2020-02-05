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
import DVB
import AVFoundation


class SearchController: ViewController {
    fileprivate var gpsFetchWasTriggered: Bool? {
        didSet {
            if gpsFetchWasTriggered == true {
                gpsView.startAnimating()
                UIView.animate(withDuration: 1.0) {
                    self.tableView.contentInset = .init(top: self.gpsViewExpandedHeight, left: 0, bottom: 128, right: 0)
                }
            } else if gpsFetchWasTriggered == false {
                gpsView.stopAnimating()
                UIView.animate(withDuration: 1.0) {
                    self.tableView.contentInset = .init(top: self.gpsViewCollapsedHeight, left: 0, bottom: 128, right: 0)
                }
            }
        }
    }
    fileprivate var gpsViewExpandedHeight: CGFloat = 168
    fileprivate let gpsViewCollapsedHeight: CGFloat = 32
    
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
    
    fileprivate let searchViewBackground = UIVisualEffectView()
    fileprivate let gpsView = GPSView()
    fileprivate let searchView = SearchView()
    fileprivate let greetingLabel = UILabel()
    fileprivate let tutorialLabel = UILabel()
    fileprivate let tableView = TableView()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var stops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareBackground()
        prepareGreeting()
        prepareTutorial()
        prepareTableView()
        prepareGPSView()
        prepareSearchViewBackground()
        prepareSearchView()
        prepareLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.viewTapDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.viewTapDelegate = nil
        
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        print(self.view.safeAreaInsets)
    }
}

extension SearchController {
    fileprivate func prepareBackground() {
        view.backgroundColor = UIColor("#ECE9E6")
    }
    
    fileprivate func prepareGreeting() {
        view.layout(greetingLabel)
            .left(48)
            .right(48)
            .top(128)
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
        showsGreeting = true
    }
    
    fileprivate func prepareTutorial() {
        view.layout(tutorialLabel)
            .left(48)
            .right(48)
            .below(greetingLabel, 8)
        tutorialLabel.textColor = Color.grey.darken4
        tutorialLabel.font = RobotoFont.light(with: 24)
        tutorialLabel.numberOfLines = 0
        let choice = [
            "Gute Fahrt!",
            "Auf gehts!",
            "Und los!",
            "Fahrkarte nicht vergessen!"
        ].randomElement()!
        tutorialLabel.text = "Du kannst nach unten wischen, um Haltestellen in deiner Nähe zu finden. Alternativ gibt es unten eine Suchleiste. \(choice)"
        showsTutorial = true
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
        tableView.contentInset = .init(top: 32, left: 0, bottom: 128, right: 0)
        tableView.backgroundColor = .clear
    }
    
    fileprivate func prepareGPSView() {
        gpsView.contentView.backgroundColor = Color.blue.base
        gpsView.cornerRadius = 32
        tableView.insertSubview(gpsView, at: 0)
        gpsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: gpsView, attribute: .height, relatedBy: .equal, toItem: tableView, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: gpsView, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    fileprivate func prepareSearchViewBackground() {
        view.layout(searchViewBackground)
            .bottom()
            .left()
            .right()
        searchViewBackground.effect = UIBlurEffect(style: .light)
        searchViewBackground.clipsToBounds = true
        searchViewBackground.layer.cornerRadius = 32.0
    }
    
    fileprivate func prepareSearchView() {
        searchViewBackground.contentView.layout(searchView)
            .edges(top: 24, left: 24, bottom: 24, right: 24)
                
        searchView.delegate = self
    }
    
    fileprivate func prepareLocationManager() {
        locationManager.delegate = self
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
    func search(query: String) {
        Stop.find(query) {
            result in
            guard let success = result.success else {return}
            self.stops = success.stops
            if let location = self.locationManager.location {
                self.stops.sort {$0.distance(from: location) ?? 0 < $1.distance(from: location) ?? 0}
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
        view.frame.origin.y = -keyboardFrame.bounds.maxY
        UIView.animate(withDuration: 0.2) {
            self.searchViewBackground.layer.cornerRadius = 0.0
        }
    }

    @objc func keyboardWillHide(notification:NSNotification){
        view.frame.origin.y = 0
        UIView.animate(withDuration: 0.2) {
            self.searchViewBackground.layer.cornerRadius = 32.0
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
        let currentLocation = manager.location!
        Stop.findNear(coord: currentLocation.coordinate) {
            result in
            
            DispatchQueue.main.async {
                self.gpsFetchWasTriggered = false
            }
            
            guard let success = result.success else {
                if #available(iOS 10.0, *) {
                    UINotificationFeedbackGenerator()
                        .notificationOccurred(.error)
                }
                let alert = UIAlertController(title: "Es gab einen Fehler bei der GPS-Ortung.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                return
            }

            if #available(iOS 10.0, *) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            self.stops = success.stops
            if let location = self.locationManager.location {
                self.stops.sort {$0.distance(from: location) ?? 0 < $1.distance(from: location) ?? 0}
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
        NotificationCenter.default.post(name: SearchController.didUpdateLocation, object: nil, userInfo: ["location": currentLocation])
    }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StopTableViewCell.reuseIdentifier, for: indexPath
        ) as! StopTableViewCell
        let stop = stops[indexPath.row]
        if cell.stop != stop {
            cell.stop = stop
        }
        if let location = locationManager.location {
            cell.location = location
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = stops[indexPath.row]
        let controller = DeparturesController()
        controller.stop = stop
        if let location = locationManager.location {
            controller.location = location
        }
        present(controller, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -gpsViewExpandedHeight && (gpsFetchWasTriggered == false || gpsFetchWasTriggered == nil) {
            gpsFetchWasTriggered = true
            requestLocation()
        }
    }
}
