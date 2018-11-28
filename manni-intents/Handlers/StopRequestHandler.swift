//
//  StopRequestHandler.swift
//  manni-intents
//
//  Created by Philipp Matthes on 22.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Intents

@available(iOSApplicationExtension 10.0, *)
class StopRequestHandler: NSObject, INRequestRideIntentHandling {
    func handle(intent: INRequestRideIntent,
                completion: @escaping (INRequestRideIntentResponse) -> Void) {
        let response = INRequestRideIntentResponse(
            code: .failureRequiringAppLaunchNoServiceInArea,
            userActivity: .none)
        completion(response)
    }
    
    
}
