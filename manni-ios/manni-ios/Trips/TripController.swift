//
//  TripController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 11.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB


class TripController: ViewController {
    
    public var stop: Stop?
    public var departure: Departure? {
        didSet {
            departureLineLabel.text = "Fahrplan für Linie \(departure?.line ?? "")"
            departureDirectionLabel.text = "Richtung \(departure?.direction ?? "")"
            tripView.departure = departure
        }
    }
    
    fileprivate let tripView = TripView()
    fileprivate let topView = SkeuomorphismView()
    fileprivate let departureLineLabel = UILabel()
    fileprivate let departureDirectionLabel = UILabel()
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTripView()
        prepareTopView()
        prepareBackButton()
        prepareDepartureLineLabel()
        prepareDepartureDirectionLabel()
        
        TripStop.get(forTripID: departure!.id, stopID: stop!.id, atTime: Date()) {
            response in
            guard let success = response.success else {
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UINotificationFeedbackGenerator()
                            .notificationOccurred(.error)
                    }
                    let alert = UIAlertController(title: "VVO-Schnittstelle nicht erreichbar.", message: "Bitte versuche es später erneut.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.tripView.tripStops = success.stops
            }
        }
    }
    
    @objc func backButtonTouched() {
        self.dismiss(animated: true)
    }
    
}

extension TripController {
    fileprivate func prepareTopView() {
        view.layout(topView)
            .top()
            .left()
            .right()
            .height(218)
        topView.cornerRadius = 10
        topView.gradient = Gradients.clouds
        topView.darkShadowOpacity = 0.1
    }
    
    fileprivate func prepareBackButton() {
        topView.contentView.layout(backButton)
            .top(24)
            .left(24)
            .height(64)
            .width(64)
        backButton.skeuomorphismView.lightShadowOpacity = 0.3
        backButton.skeuomorphismView.darkShadowOpacity = 0.2
        backButton.pulseColor = Color.blue.base
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
    }
    
    fileprivate func prepareDepartureLineLabel() {
        topView.contentView.layout(departureLineLabel)
            .below(backButton, 24)
            .left(24)
            .right(24)
            .height(32)
        departureLineLabel.font = RobotoFont.bold(with: 24)
        departureLineLabel.textColor = Color.grey.darken4
        departureLineLabel.numberOfLines = 1
    }
    
    fileprivate func prepareDepartureDirectionLabel() {
        topView.contentView.layout(departureDirectionLabel)
            .below(departureLineLabel, 8)
            .left(24)
            .height(32)
            .right(24)
        departureDirectionLabel.font = RobotoFont.light(with: 18)
        departureDirectionLabel.textColor = Color.grey.darken4
        departureDirectionLabel.numberOfLines = 1
    }
    
    fileprivate func prepareTripView() {
        view.layout(tripView)
            .top(208)
            .bottom()
            .left()
            .right()
        tripView.cornerRadius = 0
    }
}
