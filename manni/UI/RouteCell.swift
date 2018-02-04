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

class RouteCell: TableViewCell {
    static let identifier = "routeCell"
    static let closedHeight: CGFloat = 100
    
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lowerLabel: UILabel!
    
    var route: Route!
    var filteredPartialRoutes: [Route.RoutePartial]!
    
    func configure(_ route: Route) {
        self.route = route
        self.filteredPartialRoutes = route.partialRoutes
            .filter { $0.partialRouteId != nil }
            .sorted { $0.partialRouteId! < $1.partialRouteId! }
        
        upperLabel.text = "\(route.duration) min - \(route.interchanges) Umstiege"
        lowerLabel.text = "\(filteredPartialRoutes.first!.regularStops!.first!.departureTime.time()) - \(filteredPartialRoutes.last!.regularStops!.last!.departureTime.time())"
        
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
                }
            }
        }
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
