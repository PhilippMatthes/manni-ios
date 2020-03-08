//
//  DepartureViews.swift
//  manni-watchos Extension
//
//  Created by It's free real estate on 07.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import CoreLocation
import DVB


struct DepartureListView: View {
    public var stop: Stop
    @State private var departures = [Departure]()
    
    var body: some View {
        List {
            ForEach(departures, id: \.id) {
                departure in
                DepartureRowView(departure: departure)
            }
        }
        .navigationBarTitle("Abfahrten")
        .listStyle(CarouselListStyle())
        .onAppear(perform: loadDepartures)
    }
    
    func loadDepartures() {
        stop.monitor {
            response in
            if let success = response.success {
                self.departures = success.departures
            }
        }
    }
}

struct DepartureRowView: View {
    var departure: Departure
    
    var body: some View {
            VStack(alignment: HorizontalAlignment.leading, spacing: 4) {
                Text("\(departure.line) \(departure.direction)")
                    .font(.headline)
                Text("\(departure.realTime?.shortETAString ?? departure.scheduledTime.shortETAString)")
                    .font(.subheadline)
                if (departure.manniLatency != nil) {
                    Spacer(minLength: 4)
                    Text(departure.manniLatency!)
                        .font(.footnote)
                        .foregroundColor(Color.black)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.white.opacity(0.3), radius: 4, x: -4, y: -4)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                }
            }
            .listRowBackground(
                LinearGradient(
                    gradient: Gradient(
                        colors: departure.gradient.map {
                            Color($0)
                        }
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(8)
                .shadow(
                    color: Color(
                        departure.gradient.first!
                    ).opacity(0.3),
                    radius: 4,
                    x: 0,
                    y: -4
                )
            )
            .padding(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
        }
}

#if DEBUG

struct DepartureListView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureListView(stop: Stop(id: "33000028", name: "Hauptbahnhof", region: nil, location: nil))
    }
}

#endif
