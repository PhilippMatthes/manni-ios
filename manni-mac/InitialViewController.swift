//
//  ViewController.swift
//  manni-mac
//
//  Created by Philipp Matthes on 21.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Cocoa
import DVB

class InitialViewController: NSViewController {

    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var table: NSTableView!
    
    var stops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        search.delegate = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    static func instanciate() -> InitialViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "InitialViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? InitialViewController else {
            fatalError("Can't find InitialViewController")
        }
        return viewcontroller
    }

    func update(query: String) {
        Stop.find(query) {
            result in
            DispatchQueue.main.async {
                guard let response = result.success else {return}
                self.stops = response.stops
                self.table.reloadData()
            }
        }
    }

}

extension InitialViewController: NSTableViewDataSource, NSTableViewDelegate {
    fileprivate enum CellIDs {
        static let StopCell = "StopCell"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let stop = stops[row]
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIDs.StopCell), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = stop.region == nil ? "\(stop.name)" : "\(stop.name) (\(stop.region!))"
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if table.selectedRowIndexes.count < 1 {return}
        guard let index = table.selectedRowIndexes.first else {return}
        let stop = stops[index]
        view.window?.contentViewController = DepartureController.instanciate(stop)
    }
}

extension InitialViewController: NSSearchFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else {return}
        update(query: searchField.stringValue)
    }
}

