//
//  IntentHandler.swift
//  manni-intents
//
//  Created by Philipp Matthes on 22.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

@available(iOSApplicationExtension 10.0, *)
class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        if intent is INRequestRideIntent {
            return StopRequestHandler()
        }
        return .none
    }
}

