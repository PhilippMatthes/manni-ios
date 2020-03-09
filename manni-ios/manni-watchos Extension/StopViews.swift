//
//  StopViews.swift
//  manni-watchos Extension
//
//  Created by It's free real estate on 07.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation
import DVB


enum StopViewAlert {
    case locationAccessDenied
    case locationAccessPending
    case apiFailure
    case gpsFailure
}


class StopViewOrchestrator: NSObject, ObservableObject, CLLocationManagerDelegate {
    public let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published public var showAlert: Bool = false {
        willSet {objectWillChange.send()}
    }
    
    @Published public var alertType: StopViewAlert? {
        willSet {objectWillChange.send()}
    }
    
    @Published public var stops: [Stop] = [] {
        willSet {objectWillChange.send()}
    }
    
    @Published public var location: CLLocation? {
        willSet {objectWillChange.send()}
    }
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    init(
        showAlert: Bool = false,
        alertType: StopViewAlert? = nil,
        stops: [Stop] = [],
        location: CLLocation? = nil
    ) {
        super.init()
        self.showAlert = showAlert
        self.alertType = alertType
        self.stops = stops
        self.location = location
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    public func requestLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            WKInterfaceDevice.current().play(.retry)
            locationManager.requestWhenInUseAuthorization()
            alertType = .locationAccessPending
            showAlert = true
            return
        }
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            WKInterfaceDevice.current().play(.start)
            locationManager.requestLocation()
            return
        }
        WKInterfaceDevice.current().play(.failure)
        alertType = .locationAccessDenied
        showAlert = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        WKInterfaceDevice.current().play(.failure)
        alertType = .gpsFailure
        showAlert = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = manager.location else {return}
        
        self.location = currentLocation
        
        Stop.findNear(coord: currentLocation.coordinate) {
            result in
            guard let success = result.success else {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.failure)
                    
                    self.alertType = .apiFailure
                    self.showAlert = true
                }
                return
            }

            WKInterfaceDevice.current().play(.success)
            
            var fetchedStops = success.stops
            if let location = self.locationManager.location {
                fetchedStops.sort {$0.approximateDistance(from: location) ?? 0 < $1.approximateDistance(from: location) ?? 0}
            }
            
            DispatchQueue.main.async {
                self.stops = fetchedStops
            }
        }
    }
}


struct StopView: View {
    @EnvironmentObject var orchestrator: StopViewOrchestrator
    
    var body: some View {
        List {
            Button(action: {self.orchestrator.requestLocation()}) {
                VStack {
                    Text("Haltestellen laden")
                        .font(.headline)
                    Text("Nach Haltestellen in der Umgebung suchen")
                        .font(.footnote)
                }
            }
            .alert(isPresented: self.$orchestrator.showAlert) {
                switch self.orchestrator.alertType {
                case .locationAccessDenied:
                    return Alert(title: Text("GPS-Zugriff verboten"), message: Text("Du hast der App den GPS-Zugriff verboten. Erlaube den Zugriff über die Einstellungen auf deinem gepaarten Gerät und versuche es erneut."), dismissButton: .default(Text("OK")))
                case .locationAccessPending:
                    return Alert(title: Text("GPS-Zugriff noch nicht gestattet"), message: Text("Du hast der App den GPS-Zugriff noch nicht gestattet. Erlaube den Zugriff über die Einstellungen auf deinem gepaarten Gerät und versuche es erneut."), dismissButton: .default(Text("OK")))
                case .apiFailure:
                    return Alert(title: Text("Fehler mit der VVO-Schnittstelle."), message: Text("Die VVO-Schnittstelle konnte nicht kontaktiert werden oder es gab einen anderen Fehler. Bitte versuche es erneut."), dismissButton: .default(Text("OK")))
                case .gpsFailure:
                    return Alert(title: Text("Fehler bei der Ortung."), message: Text("Die Ortung konnte nicht korrekt durchgeführt werden. Bitte versuche es erneut."), dismissButton: .default(Text("OK")))
                case .none:
                    return Alert(title: Text("Unbekannter Fehler."), dismissButton: .default(Text("OK")))
                }
            }
            .multilineTextAlignment(.center)
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
            
            ForEach(self.orchestrator.stops, id: \.id) {
                stop in
                StopRowView(stop: stop, location: self.orchestrator.location)
            }
        }
        .navigationBarTitle("Haltestellen")
        .listStyle(CarouselListStyle())
    }
}


struct StopRowView: View {
    var stop: Stop
    var location: CLLocation?

    var body: some View {
        NavigationLink(destination: DepartureListView(stop: stop)) {
            VStack(alignment: HorizontalAlignment.leading) {
                Text(stop.name)
                    .font(.headline)
                    .foregroundColor(Color.black)
                Text(stop.region ?? "Dresden")
                    .font(.subheadline)
                    .foregroundColor(Color.black.opacity(0.7))
                if location != nil && stop.location != nil {
                    Text("\(location!.approximateDistance(from: CLLocation(latitude: stop.location!.latitude, longitude: stop.location!.longitude))) m entfernt")
                        .font(.footnote)
                        .foregroundColor(Color.black.opacity(0.7))
                }
            }
        }
        .listRowBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: Gradients.cloudsInverse.map {
                        Color($0)
                    }
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(8)
            .shadow(
                color: Color(
                    Gradients.cloudsInverse.first!
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

struct StopView_Previews: PreviewProvider {
    static var previews: some View {
        StopView().environmentObject(StopViewOrchestrator(
            showAlert: true,
            alertType: .locationAccessDenied,
            stops: (0...20).map {
                Stop(id: "\($0)",
                name: "Haltestelle \($0)",
                region: nil,
                location: CLLocation(latitude: 51.05089 + (Double($0) / 10000), longitude: 13.73832).coordinate)
            },
            location: CLLocation(latitude: 51.05089, longitude: 13.73832)
        ))
    }
}

#endif

