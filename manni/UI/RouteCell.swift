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
    
    var delegate: RouteCellDelegate!
    var indexPath: IndexPath!
    var route: Route!
    var filteredPartialRoutes: [Route.RoutePartial]!
    
    func configure(_ route: Route, indexPath: IndexPath, delegate: RouteCellDelegate) {
        self.delegate = delegate
        self.route = route
        self.indexPath = indexPath
        
        self.filteredPartialRoutes = route.partialRoutes
            .filter { $0.partialRouteId != nil }
            .sorted { $0.partialRouteId! < $1.partialRouteId! }
        
        configureLabels()
        configureScrollViewRecognizer()
        configureScrollView()
        configureMapViewButton()
    }
        
    func configureMapViewButton() {
        mapViewButton.tintColor = .white
        mapViewButton.titleColor = .white
        mapViewButton.pulseColor = .white
        mapViewButton.backgroundColor = Color.blue.base
    }
        
    func configureLabels() {
        upperLabel.text = "\(route.duration) min - \(route.interchanges) Umstiege"
        lowerLabel.text = "\(filteredPartialRoutes.first!.regularStops!.first!.departureTime.time()) - \(filteredPartialRoutes.last!.regularStops!.last!.departureTime.time())"
    }
    
    func configureScrollView() {
        if scrollView.layer.sublayers == nil {
            scrollView.contentSize = CGSize(width: 2*58*CGFloat(filteredPartialRoutes.count), height: scrollView.frame.height)
            let numberOfPartialRoutes = filteredPartialRoutes.count
            for i in 0..<numberOfPartialRoutes {
                let buttonFrame = CGRect(x: 8+i*96, y: 0, width: 50, height: 50)
                let button = RaisedButton(frame: buttonFrame)
                button.isEnabled = false
                
                let partialRoute =  filteredPartialRoutes[i]
                
                button.setTitle(partialRoute.mode.name, for: .normal)
                
                var color: UIColor
                if let lineName = partialRoute.mode.name {
                    if let lineID = Int(lineName) {
                        color = Colors.color(forInt: lineID)
                    } else {
                        color = Colors.color(forInt: lineName.count)
                    }
                } else {
                    color = Colors.color(forInt: partialRoute.mapDataIndex)
                }
                
                button.backgroundColor = color
                button.shadowColor = color.darker()!
                
                self.scrollView.addSubview(button)
                
                if i < numberOfPartialRoutes-1 {
                    let arrowFrame = CGRect(x: 8+i*96+58, y: 0, width: 30, height: 50)
                    let arrow = IconButton(frame: arrowFrame)
                    arrow.isEnabled = false
                    arrow.setImage(Icon.cm.play, for: .normal)
                    arrow.tintColor = UIColor.black
                    self.scrollView.addSubview(arrow)
                    if let transitArrival = partialRoute.regularStops?.last?.arrivalTime, let transitDeparture = filteredPartialRoutes[i+1].regularStops?.first?.departureTime {
                        let timeFrame = CGRect(x: 8+i*96+58, y: 0, width: 30, height: 20)
                        let timeLabel = UILabel(frame: timeFrame)
                        timeLabel.text = "\(transitDeparture.minutes(from: transitArrival)) min"
                        timeLabel.font = timeLabel.font.withSize(8)
                        timeLabel.textAlignment = .center
                        self.scrollView.addSubview(timeLabel)
                    }
                }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "partialRouteCell") as? PartialRouteCell else {return UITableViewCell()}
        cell.configure(forPartialRoute: filteredPartialRoutes[
            indexPath.row >= filteredPartialRoutes.count ? filteredPartialRoutes.count-1 : indexPath.row
            ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPartialRoutes.count
    }
}
