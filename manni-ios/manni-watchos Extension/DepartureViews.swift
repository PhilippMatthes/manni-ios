//
//  DepartureViews.swift
//  manni-watchos Extension
//
//  Created by It's free real estate on 07.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation
import DVB


enum DepartureListViewAlert {
    case apiFailure
}


class DepartureListViewOrchestrator: NSObject, ObservableObject {
    public let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published public var stop: Stop? {
        willSet {objectWillChange.send()}
    }
    
    @Published public var showAlert: Bool = false {
        willSet {objectWillChange.send()}
    }
    
    @Published public var alertType: DepartureListViewAlert? {
        willSet {objectWillChange.send()}
    }
    
    @Published public var showsLoading: Bool = true {
        willSet {objectWillChange.send()}
    }
    
    @Published public var departures: [Departure] = [] {
        willSet {objectWillChange.send()}
    }
    
    private var scheduledTimer: Timer?
    
    init(
        stop: Stop? = nil,
        showAlert: Bool = false,
        alertType: DepartureListViewAlert? = nil,
        showsLoading: Bool = true,
        departures: [Departure] = []
    ) {
        super.init()
        self.stop = stop
        self.showAlert = showAlert
        self.alertType = alertType
        self.showsLoading = showsLoading
        self.departures = departures
    }
    
    @objc func loadDepartures() {
        guard let stop = stop else {return}
        
        print("Fetch triggered")
        Departure.monitor(
            stopWithId: stop.id,
            dateType: .departure
        ) {
            result in
            
            DispatchQueue.main.async {
                // Set showsLoading only once to
                // provide a seamless experience
                self.showsLoading = false
            }
            
            guard let success = result.success else {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.failure)
                    self.alertType = .apiFailure
                    self.showAlert = true
                    self.scheduledTimer?.invalidate()
                }
                return
            }
            
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(.click)
                self.departures = success.departures
            }
            
            // Schedule next departure load
            self.scheduledTimer?.invalidate()
            self.scheduledTimer = Timer(fireAt: success.expirationTime, interval: 0, target: self, selector: #selector(self.loadDepartures), userInfo: nil, repeats: false)
            RunLoop.main.add(self.scheduledTimer!, forMode: .common)
        }
    }
}


struct DepartureListView: View {
    @EnvironmentObject var orchestrator: DepartureListViewOrchestrator
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        List {
            Button(action: {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.click)
                    self.orchestrator.showsLoading = true
                }
                self.orchestrator.loadDepartures()
            }) {
                VStack {
                    Text("Ansicht aktualisiert sich automatisch")
                        .font(.footnote)
                }
            }
            .alert(isPresented: self.$orchestrator.showAlert) {
                let retryButton = Alert.Button.default(Text("Erneut versuchen"), action: {})
                
                let dismissButton = Alert.Button.cancel(Text("Abfahrten schließen"), action: {
                    self.mode.wrappedValue.dismiss()
                })
                
                switch self.orchestrator.alertType {
                case .apiFailure:
                    return Alert(title: Text("Fehler mit der VVO-Schnittstelle."), message: Text("Die VVO-Schnittstelle konnte nicht kontaktiert werden oder es gab einen anderen Fehler. Bitte versuche es erneut."), primaryButton: retryButton, secondaryButton: dismissButton)
                case .none:
                    return Alert(title: Text("Unbekannter Fehler."), primaryButton: retryButton, secondaryButton: dismissButton)
                }
            }
            .multilineTextAlignment(.leading)
            .listRowBackground(
                LinearGradient(
                    gradient: Gradient(
                        colors: Gradients.blue.map {
                            Color($0)
                        }
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(8)
                .shadow(
                    color: Color(
                        Gradients.blue.first!
                    ).opacity(0.3),
                    radius: 4,
                    x: 0,
                    y: -4
                )
            )
            .padding(EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4))
            
            if (orchestrator.showsLoading) {
                DepartureRowView(departure: nil)
                DepartureRowView(departure: nil)
                DepartureRowView(departure: nil)
            } else {
                ForEach(orchestrator.departures, id: \.id) {
                    departure in
                    DepartureRowView(departure: departure)
                }
            }
        }
        .navigationBarTitle("Abfahrten")
        .listStyle(CarouselListStyle())
        .onAppear(perform: orchestrator.loadDepartures)
    }
}

struct DepartureRowView: View {
    var departure: Departure?
    
    @State var loadingColor = Color.gray.opacity(0.3)
    
    var loadingAnimation: Animation {
        return Animation
            .easeInOut(duration: 0.5)
            .repeatForever()
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 4) {
            if departure != nil {
                Text("\(departure!.line) \(departure!.direction)")
                    .font(.headline)
                Text("\(departure!.realTime?.shortETAString ?? departure!.scheduledTime.shortETAString)")
                    .font(.subheadline)
                if (departure!.manniLatency != nil) {
                    Spacer(minLength: 4)
                    Text(departure!.manniLatency!)
                        .font(.footnote)
                        .foregroundColor(Color.black)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.white.opacity(0.3), radius: 4, x: -4, y: -4)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 4, y: 4)
                }
            } else {
                HStack {
                    Text(" ")
                        .font(.headline)
                    Spacer()
                }
                .background(loadingColor)
                .cornerRadius(4)
                .onAppear {
                    withAnimation(self.loadingAnimation) {
                        self.loadingColor = Color.gray.opacity(0.5)
                    }
                }
                HStack {
                    Text(" ")
                        .font(.subheadline)
                    Spacer()
                }
                .background(loadingColor)
                .cornerRadius(4)
                .onAppear {
                    withAnimation(self.loadingAnimation) {
                        self.loadingColor = Color.gray.opacity(0.5)
                    }
                }
            }
        }
        .listRowBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: departure?.gradient.map {
                        Color($0)
                    } ?? Gradients.clouds.map {
                        Color($0)
                    }
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(8)
            .shadow(
                color: Color(
                    departure?.gradient.first ?? Gradients.clouds.first!
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
        Group {
            DepartureListView().environmentObject(
                DepartureListViewOrchestrator(
                    showsLoading: true
                )
            )
            DepartureListView().environmentObject(
                DepartureListViewOrchestrator(
                    stop: Stop(id: "33000028", name: "Hauptbahnhof", region: nil, location: nil),
                    showsLoading: false,
                    departures: (0...20).map {
                        Departure(id: "\($0)", line: "\($0)", direction: "Dresden", mode: .bus, scheduledTime: Date().addingTimeInterval(1000 * Double($0)))
                    }
                )
            )
            DepartureListView().environmentObject(
                DepartureListViewOrchestrator(
                    showAlert: true,
                    alertType: .apiFailure
                )
            )
        }
    }
}

#endif
