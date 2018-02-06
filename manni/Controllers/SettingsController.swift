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
import Motion

class SettingsController: UITableViewController {
    
    @IBOutlet weak var predictionActivationCell: TableViewCell!
    
    @IBOutlet weak var predictionActivationSwitch: Switch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predictionActivationSwitch.delegate = self
        predictionActivationSwitch.setSwitchState(state: State.shared.predictionsActive ? .on : .off)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationItem.titleLabel.text = "Einstellungen"
        navigationItem.titleLabel.textColor = UIColor.black
        let backButton = UIButton(type: .custom)
        backButton.setImage(Icon.cm.arrowBack, for: .normal)
        backButton.tintColor = UIColor.black
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.setTitle(Config.backButtonTitle, for: .normal)
        backButton.addTarget(self, action: #selector(self.returnBack), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
        navigationItem.hidesBackButton = false
    }
}

extension SettingsController: SwitchDelegate {
    func switchDidChangeState(control: Switch, state: SwitchState) {
        if control == predictionActivationSwitch { State.shared.predictionsActive = state == .on }
    }
}
