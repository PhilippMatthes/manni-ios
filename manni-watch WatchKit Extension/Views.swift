//
//  StopList.swift
//  manni-watch WatchKit Extension
//
//  Created by Philipp Matthes on 05.07.19.
//  Copyright © 2019 Philipp Matthes. All rights reserved.
//

import Combine
import SwiftUI
import DVB

extension URLSession {
    static var fuckWatchOS: URLSession {
        get {
            let config = URLSessionConfiguration.default
    
            config.requestCachePolicy = .reloadIgnoringLocalCacheData //deactivate cache
            config.urlCache = nil
    
            return URLSession(configuration: config)
        }
    }
}

extension Stop {
    
    struct StopList: View {
        var location: CLLocationCoordinate2D
        
        var stops = [Stop]()
        
        var body: some View {
            List {
                ForEach(self.stops.identified(by: \.self)) { stop in
                    Stop.StopCell(stop: stop)
                }
            }
            .onAppear() {
                Stop.findNear(lat: self.location.latitude, lng: self.location.longitude, session: .fuckWatchOS) {
                    response in
                    print(response)
                }
            }
            .navigationBarTitle(Text("Stops"))
        }
        
    }
    
    struct StopCell: View {
        var stop: Stop
        
        var body: some View {
            let color = Colors.color(forInt: stop.name.count)
            let rgb = color.getRGB()!
            let r = Double(rgb.red) / 255.0
            let g = Double(rgb.green) / 255.0
            let b = Double(rgb.blue) / 255.0
            let swiftUIColor = Color(red: r, green: g, blue: b)
            return NavigationLink(destination: Departure.DepartureList(stop: stop)) {
                Text(stop.name)
            }
            .listRowPlatterColor(
                swiftUIColor
            )
        }
    }
}

extension Departure {
    struct DepartureList: View {
        var stop: Stop
        
        var departures = [Departure]()
        
        var body: some View {
            List {
                ForEach(departures.identified(by: \.self)) { departure in
                    Departure.DepartureCell(departure: departure)
                }
            }
            .onAppear() {
                print(self.stop)
            }
            .navigationBarTitle(Text("Departures"))
        }
    }
    
    struct DepartureCell: View {
        var departure: Departure
        
        var body: some View {
            Text(departure.description)
        }
    }
}

#if DEBUG
struct StopList_Previews : PreviewProvider {
    static var previews: some View {
        let location = CLLocationCoordinate2D(latitude: 51.050407, longitude: 13.737262)
        
        return Stop.StopList(location: location)
    }
}
#endif
