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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predictionActivationSwitch.delegate = self
        predictionActivationSwitch.setSwitchState(state: State.shared.predictionsActive ? .on : .off)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = Config.settings
    }
    
    override var prefersStatusBarHidden: Bool {
        return Device.runningOniPhoneX
    }
}

extension SettingsController: SwitchDelegate {
    func switchDidChangeState(control: Switch, state: SwitchState) {
        if control == predictionActivationSwitch { State.shared.predictionsActive = state == .on }
    }
}
