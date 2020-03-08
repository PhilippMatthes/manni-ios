//
//  HostingController.swift
//  manni-watchos Extension
//
//  Created by It's free real estate on 07.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import SwiftUI
import DVB
import UIKit

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(StopView().environmentObject(StopViewOrchestrator()))
    }
}
