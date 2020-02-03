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


class SearchController: ViewController {
    fileprivate let searchViewBackground = UIVisualEffectView()
    fileprivate let searchView = SearchView()

    fileprivate let tableView = TableView()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var stops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareBackgroundView()
        prepareTableView()
        prepareSearchViewBackground()
        prepareSearchView()
        prepareLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchController {
    fileprivate func prepareBackgroundView() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor("#ECE9E6").cgColor, UIColor("#E0E0E0").cgColor]
        gradient.frame = self.view.bounds
        self.view.layer.addSublayer(gradient)
    }
    
    fileprivate func prepareTableView() {
        view.layout(tableView).edges()
        tableView.register(
            StopTableViewCell.self,
            forCellReuseIdentifier: StopTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: 128, right: 0)
        tableView.backgroundColor = .clear
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
            .edgesSafe(top: 24, left: 24, bottom: 24, right: 24)
        searchView.textField.delegate = self
        searchView.searchButton.addTarget(self, action: #selector(searchStop), for: .touchUpInside)
    }
    
    fileprivate func prepareLocationManager() {
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

extension SearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchStop()
        return true
    }
    
    @objc func searchStop() {
        searchView.textField.resignFirstResponder()
        guard let query = searchView.textField.text, query != "" else {
            return
        }
        
        Stop.find(query) {
            result in
            guard let success = result.success else {return}
            self.stops = success.stops
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
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        else {return}
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        view.frame.origin.y = -keyboardFrame.size.height
    }

    @objc func keyboardWillHide(notification:NSNotification){
        view.frame.origin.y = 0
    }
}

extension SearchController: CLLocationManagerDelegate {
    static let didUpdateLocation = Notification.Name("didUpdateLocation")
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = manager.location else {return}
        Stop.findNear(coord: currentLocation.coordinate) {
            result in
            guard let success = result.success else {return}
            self.stops = success.stops
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
        cell.stop = stops[indexPath.row]
        if let location = locationManager.location {
            cell.location = location
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = stops[indexPath.row]
        let controller = DeparturesController()
        controller.stop = stop
        show(controller, sender: self)
    }

}
