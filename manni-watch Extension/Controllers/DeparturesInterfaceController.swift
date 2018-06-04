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
    
    @IBOutlet var indicator: WKInterfaceImage!
    @IBOutlet var table: WKInterfaceTable!
    
    var departures = [Departure]()
    var station: Station!
    var stop: Stop?
    
    
    @IBAction func refreshButtonPressed() {
        loadDepartures(station: station) {}
    }
    
    func startAnimatingLoading() {
        table.setHidden(true)
        indicator.setHidden(false)
        indicator.setImageNamed("animation")
        indicator.startAnimating()
    }
    
    func stopAnimatingLoading() {
        indicator.setHidden(true)
        table.setHidden(false)
        indicator.stopAnimating()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let station = context as? Station else { return }
        self.station = station
        
        loadDepartures(station: self.station) {}
    }
    
    func showPrompt() {
        let action1 = WKAlertAction(title: Config.refresh, style: .default) {
            self.loadDepartures(station: self.station) {}
        }
        let action2 = WKAlertAction(title: Config.cancel, style: .destructive) {
            self.dismiss()
        }
        presentAlert(withTitle: Config.thereWasAProblemDownloading, message: "", preferredStyle: .actionSheet, actions: [action1,action2])
    }
    
    func loadDepartures(station: Station, completion: @escaping () -> ()) {
        self.startAnimatingLoading()
        Stop.find(station.id) { result in
            switch result {
            case .failure(_):
                self.showPrompt()
                return
            case let .success(response):
                guard let first = response.stops.first else {
                    self.showPrompt()
                    return
                }
                self.stop = first
                Departure.monitor(stopWithId: first.id) {
                    result in
                    guard let response = result.success else {
                        self.showPrompt()
                        return
                    }
                    self.departures = response.departures
                    DispatchQueue.main.async{
                        self.reloadTableView()
                        self.stopAnimatingLoading()
                    }
                }
            }
        }
    }
    
    func reloadTableView() {
        self.table.setNumberOfRows(self.departures.count, withRowType: "DepartureRow")
        for i in 0..<self.departures.count {
            guard let controller = self.table.rowController(at: i) as? DepartureRowController else { return }
            let departure = self.departures[i]
            
            var color: UIColor
            if let lineNumber = Int(departure.line) {
                color = Colors.color(forInt: lineNumber)
            } else {
                color = Colors.color(forInt: departure.line.count)
            }
            
            controller.group.setBackgroundColor(color)
            controller.configure(time: departure.realTime ?? departure.scheduledTime, line: departure.line, direction: departure.direction)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let stopId = stop?.id else {return}
        let departure = departures[rowIndex]
        let tripId = departure.id
        presentController(withName: "LocationInterfaceController", context: [stopId, tripId])
    }
    
}
