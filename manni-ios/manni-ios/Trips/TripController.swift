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
    
    public var stop: Stop? {
        didSet {
            tripView.stop = stop
        }
    }
    public var departure: Departure? {
        didSet {
            departureLineLabel.text = "Fahrplan für Linie \(departure?.line ?? "")"
            departureDirectionLabel.text = "Richtung \(departure?.direction ?? "")"
            tripView.departure = departure
            
            if let latency = departure?.manniLatency {
                disclaimerLabel.text = "Die Abfahrt an der aktuellen Haltestelle ist \(latency). Der gezeigte reguläre Fahrplan kann abweichen."
            } else {
                disclaimerLabel.text = "Der gezeigte reguläre Fahrplan kann von der tatsächlichen Abfahrtszeit abweichen."
            }
        }
    }
    
    fileprivate let tripView = TripView()
    fileprivate let topView = SkeuomorphismView()
    fileprivate let departureLineLabel = UILabel()
    fileprivate let departureDirectionLabel = UILabel()
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    fileprivate let disclaimerBackgroundView = UIVisualEffectView()
    fileprivate let disclaimerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTripView()
        prepareTopView()
        prepareBackButton()
        prepareDepartureLineLabel()
        prepareDepartureDirectionLabel()
        prepareDisclaimerView()
        
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
        navigationController?.popViewController(animated: true)
    }
    
}

extension TripController {
    fileprivate func prepareTripView() {
        view.layout(tripView)
            .top()
            .bottom()
            .left()
            .right()
        tripView.cornerRadius = 0
        tripView.tableViewContentInset = .init(top: 188, left: 0, bottom: 128, right: 0)
    }
    
    fileprivate func prepareTopView() {
        view.layout(topView)
            .top()
            .left()
            .right()
            .height(188)
        topView.gradient = Gradients.clouds
        topView.darkShadowOpacity = 0.1
        topView.lightShadowOpacity = 0.3
        topView.roundedCorners = .bottomLeft
        topView.cornerRadius = 24
        topView.motionIdentifier = "TopView"
    }
    
    fileprivate func prepareBackButton() {
        topView.contentView.layout(backButton)
            .topSafe(12)
            .left(24)
            .height(64)
            .width(64)
        backButton.skeuomorphismView.lightShadowOpacity = 0.3
        backButton.skeuomorphismView.darkShadowOpacity = 0.2
        backButton.pulseColor = Color.blue.base
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        backButton.motionIdentifier = "BackButton"
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
    
    fileprivate func prepareDisclaimerView() {
        view.layout(disclaimerBackgroundView)
            .bottomSafe(12)
            .left(52)
            .right(12)
        disclaimerBackgroundView.layer.cornerRadius = 12
        disclaimerBackgroundView.clipsToBounds = true
        disclaimerBackgroundView.effect = UIBlurEffect(style: .light)
        
        disclaimerBackgroundView.contentView.layout(disclaimerLabel)
            .edges(top: 12, left: 12, bottom: 12, right: 12)
        disclaimerLabel.font = RobotoFont.light(with: 14)
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.textColor = .white
    }
}
