//
//  SettingsController.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

class SettingsController: UIViewController {
       
    @IBOutlet weak var predictionActivationSwitch: Switch!
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predictionActivationSwitch.delegate = self
        predictionActivationSwitch.setSwitchState(state: State.shared.predictionsActive ? .on : .off)
        prepareTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = Config.settings
    }
    
    override var prefersStatusBarHidden: Bool {
        return Device.runningOniPhoneX
    }
    
    func prepareTable() {
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 15.0
    }
}

extension SettingsController: SwitchDelegate {
    func switchDidChangeState(control: Switch, state: SwitchState) {
        if control == predictionActivationSwitch { State.shared.predictionsActive = state == .on }
    }
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func date(byIndexPath indexPath: IndexPath) -> Date? {
        guard
            let day = Calendar.current.date(byAdding: .day, value: indexPath.section, to: Date()),
            let calendar = NSCalendar(calendarIdentifier: .gregorian)
            else {return nil}
        return calendar.date(bySettingHour: indexPath.row, minute: 0, second: 0, of: day, options: .matchFirst)
    }
    
    func date(bySection section: Int) -> Date? {
        let indexPath = IndexPath(row: 0, section: section)
        return date(byIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let date = date(byIndexPath: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: "PredictionCell") as? PredicitonCell
        else {return UITableViewCell()}
        cell.prepare(forDate: date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let date = date(bySection: section) else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PredicitonCell.height
    }
    
    
}
