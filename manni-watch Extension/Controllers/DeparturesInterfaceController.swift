//
//  DepartuesController.swift
//  manni-watch Extension
//
//  Created by Philipp Matthes on 20.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import WatchKit
import DVB
import CoreLocation

class DeparturesInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    
    var departures = [Departure]()
    var station: Station!
    
    func showCells(_ text: String...) {
        table.setNumberOfRows(text.count, withRowType: "DepartureRow")
        
        for i in 0..<text.count {
            guard let controller = table.rowController(at: i) as? DepartureRowController else { return }
            controller.label.setText(text[i])
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let station = context as? Station else { return }
        self.station = station
        
        showCells(Config.loadingLiveMonitor)
        
        loadDepartures()
    }
    
    func loadDepartures() {
        Departure.monitor(stopWithName: self.station.id) {
            result in
            guard let response = result.success else {
                self.showCells(Config.thereWasAProblemDownloading)
                return
            }
            self.departures = response.departures
            self.table.setNumberOfRows(self.departures.count+1, withRowType: "DepartureRow")
            guard let controller = self.table.rowController(at: 0) as? DepartureRowController else { return }
            controller.label.setText(Config.refresh)
            for i in 0..<self.departures.count {
                guard let controller = self.table.rowController(at: i+1) as? DepartureRowController else { return }
                let departure = self.departures[i]
                
                var color: UIColor
                if let lineNumber = Int(departure.line) {
                    color = Colors.color(forInt: lineNumber)
                } else {
                    color = Colors.color(forInt: departure.line.count)
                }
                
                controller.group.setBackgroundColor(color)
                controller.label.setText("\(departure.line) \(departure.direction) in \(departure.ETA) min")
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 0 {
            guard let controller = table.rowController(at: rowIndex) as? DepartureRowController else { return }
            controller.label.setText(Config.refreshing)
            loadDepartures()
        }
    }
    
}
