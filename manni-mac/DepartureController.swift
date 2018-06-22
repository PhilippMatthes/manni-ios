//
//  DepartureController.swift
//  manni-mac
//
//  Created by Philipp Matthes on 21.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Cocoa
import DVB

class DepartureController: NSViewController {
    
    @IBOutlet weak var table: NSTableView!
    
    var departures = [Departure]()
    
    static func instanciate(_ stop: Stop) -> DepartureController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "DepartureController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DepartureController else {
            fatalError("Can't find DepartureController")
        }
        viewcontroller.update(stop: stop)
        return viewcontroller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func update(stop: Stop) {
        Departure.monitor(stopWithId: stop.id) {
            result in
            DispatchQueue.main.async {
                guard let response = result.success else {return}
                self.departures = response.departures
                self.table.reloadData()
            }
        }
    }
}

extension DepartureController: NSTableViewDataSource, NSTableViewDelegate {
    fileprivate enum CellIDs {
        static let DepartureCell = "DepartureCell"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return departures.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let departure = departures[row]
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIDs.DepartureCell), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = departure.description
            return cell
        }
        return nil
    }
}


