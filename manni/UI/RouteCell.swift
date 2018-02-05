//
//  Section.swift
//  manni
//
//  Created by Philipp Matthes on 03.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material
import Motion

protocol RouteCellDelegate {
    func showMapButtonPressed(route: Route)
    func scrollViewTapped(_ indexPath: IndexPath)
}

class RouteCell: TableViewCell {
    static let identifier = "routeCell"
    static let closedHeight: CGFloat = 100
    
    @IBOutlet weak var mapViewButton: RaisedButton!
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var topBackgroundView: UIView!
    
    var delegate: RouteCellDelegate!
    var indexPath: IndexPath!
    var route: Route!
    var allowedRows: Int!
    
    func configure(_ route: Route, indexPath: IndexPath, delegate: RouteCellDelegate) {
        self.delegate = delegate
        self.route = route
        self.indexPath = indexPath
        
        configureTopBackgroundView()
        configureTableView()
        configureLabels()
        configureScrollViewRecognizer()
        configureScrollView()
        configureMapViewButton()
    }
    
    func configureTopBackgroundView() {
        topBackgroundView.backgroundColor = .white
        topBackgroundView.alpha = 0.9
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.canCancelContentTouches = true
        tableView.contentInset = UIEdgeInsets(top: 140, left: 0, bottom: 0, right: 0)
    }
    
    func configureMapViewButton() {
        mapViewButton.tintColor = .white
        mapViewButton.titleColor = .white
        mapViewButton.pulseColor = .white
        mapViewButton.backgroundColor = Color.grey.base
        mapViewButton.alpha = 0.9
    }
        
    func configureLabels() {
        upperLabel.text = "\(route.duration) min - \(route.interchanges) Umstiege"
        let times = route.partialRoutes
            .flatMap { $0 }
            .filter { $0.regularStops != nil }
            .flatMap { $0.regularStops! }
            .map { [$0.arrivalTime, $0.departureTime] }
            .flatMap { $0 }
        let sortedTimes = times.sorted { $0 < $1 }
        if let first = sortedTimes.first, let last = sortedTimes.last {
            lowerLabel.text = "\(first.time()) - \(last.time())"
        } else {
            lowerLabel.text = "Dauer nicht bestimmbar"
        }
    }
    
    func configureScrollView() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        let numberOfModes = route.modeChain.count
        scrollView.contentSize = CGSize(width: 2*58*CGFloat(numberOfModes), height: scrollView.frame.height)
        for i in 0..<numberOfModes {
            let buttonFrame = CGRect(x: 8+i*96, y: 0, width: 50, height: 50)
            let button = RaisedButton(frame: buttonFrame)
            button.isEnabled = false
            
            let mode =  route.modeChain[i]
            
            button.setTitle(mode.name, for: .normal)
            
            var color: UIColor
            if let lineName = mode.name {
                if let lineID = Int(lineName) {
                    color = Colors.color(forInt: lineID)
                } else {
                    color = Colors.color(forInt: lineName.count)
                }
            } else {
                color = Colors.color(forInt: 0)
            }
            
            button.backgroundColor = color
            button.shadowColor = color.darker()!
            
            self.scrollView.addSubview(button)
            
            if i < numberOfModes-1 {
                let arrowFrame = CGRect(x: 8+i*96+58, y: 0, width: 30, height: 50)
                let arrow = IconButton(frame: arrowFrame)
                arrow.isEnabled = false
                arrow.setImage(Icon.cm.play, for: .normal)
                arrow.tintColor = UIColor.black
                self.scrollView.addSubview(arrow)
            }
        }
    }
    
    func configureScrollViewRecognizer() {
        let scrollViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTapGestureRecognizer.numberOfTapsRequired = 1
        scrollViewTapGestureRecognizer.isEnabled = true
        scrollViewTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(scrollViewTapGestureRecognizer)
    }
    
    @objc func scrollViewTapped() {
        delegate.scrollViewTapped(indexPath)
    }
    
    @IBAction func mapViewButtonPressed(_ sender: UIButton) {
        State.shared.route = route
        delegate.showMapButtonPressed(route: route)
    }
    
}

extension RouteCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let partialRoute = route.partialRoutes[indexPath.row]
        if partialRoute.partialRouteId != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "partialRouteCell") as? PartialRouteCell
                else {return UITableViewCell()}
            cell.configure(forPartialRoute: partialRoute)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "interchangeCell") as? TableViewCell
                else {return UITableViewCell()}
            cell.textLabel?.font = cell.textLabel?.font.withSize(10)
            let duration = partialRoute.duration == nil ? nil : "Dauer: \(partialRoute.duration!) min"
            if var identifier = partialRoute.mode.mode?.identifier {
                if identifier == "Footpath" { identifier = "Fußweg" }
                if identifier == "MobilityStairsUp" { identifier = "Treppensteigen aufwärts notwendig" }
                if identifier == "MobilityStairsDown" { identifier = "Treppensteigen abwärts notwendig" }
                cell.textLabel?.text = [identifier, duration].flatMap{ $0 }.joined(separator: ", ")
            } else {
                let identifier = "Eventuell Standortwechsel notwendig"
                cell.textLabel?.text = [identifier, duration].flatMap{ $0 }.joined(separator: ", ")
            }
            cell.backgroundColor = Color.grey.base
            cell.textLabel?.textColor = UIColor.white
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let partialRoute = route.partialRoutes[indexPath.row]
        return partialRoute.partialRouteId == nil ? 20 : 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return route.partialRoutes.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PartialRouteCell else {return}
        cell.tearDown()
    }
}
