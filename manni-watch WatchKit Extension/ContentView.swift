//
//  ContentView.swift
//  manni-watch WatchKit Extension
//
//  Created by Philipp Matthes on 05.07.19.
//  Copyright © 2019 Philipp Matthes. All rights reserved.
//

import SwiftUI
import DVB

struct ContentView : View {
    var body: some View {
        let location = CLLocationCoordinate2D(latitude: 51.050407, longitude: 13.737262)
        
        return Stop.StopList(location: location)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
