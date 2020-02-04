//
//  StopTableViewCell.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB
import CoreLocation

class StopTableViewCell: UITableViewCell {
    fileprivate let leftBorderView = SkeuomorphismView()
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let rightButton = SkeuomorphismIconButton(image: Icon.place, tintColor: Color.grey.darken4)
    fileprivate let stopNameLabel = UILabel()
    fileprivate let stopLocationLabel = UILabel()
    
    public static let reuseIdentifier = "StopTableViewCell"
    
    public var stop: Stop? {
        didSet {
            leftBorderView.lightColor = stop?.color ?? .white
            stopNameLabel.text = stop?.name
            stopLocationLabel.text = stop?.region ?? "Dresden"
            
            if let stop = stop {
                stopNameLabel.motionIdentifier = "stopNameLabel_\(stop.id)"
            }
        }
    }
    
    public var location: CLLocation? {
        didSet {
            if let location = location, let distance = stop?.distance(from: location) {
                let distanceStr = distance > 1000 ? "\(distance / 1000) km" : "\(distance) m"
                stopLocationLabel.text = "\(distanceStr) entfernt, in \(stop?.region ?? "Dresden")"
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    func prepare() {
        stopNameLabel.text = "Lade Haltestelle..."
        stopLocationLabel.text = "Lade Ort..."
        
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.layout(skeuomorphismView)
            .edges(top: 12, left: 12, bottom: 12, right: 12)
        skeuomorphismView.contentView.backgroundColor = Color.grey.lighten4
        skeuomorphismView.cornerRadius = 12
        
        contentView.layout(rightButton)
            .right(24)
            .height(64)
            .width(64)
            .centerY()
        rightButton.skeuomorphismView.lightColor = Color.grey.lighten5
        
        contentView.layout(leftBorderView)
            .left(12)
            .top(12)
            .bottom(12)
            .width(12)
        leftBorderView.cornerRadius = 6
        
        contentView.layout(stopNameLabel)
            .top(24)
            .left(48)
            .right(112)
        stopNameLabel.font = RobotoFont.bold(with: 24)
        stopNameLabel.textColor = Color.grey.darken4
        stopNameLabel.numberOfLines = 0
        
        contentView.layout(stopLocationLabel)
            .below(stopNameLabel, 8)
            .left(48)
            .right(112)
            .bottom(24)
        stopLocationLabel.font = RobotoFont.light(with: 18)
        stopLocationLabel.textColor = Color.grey.darken2
        stopLocationLabel.numberOfLines = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: SearchController.didUpdateLocation, object: nil)
    }
    
    @objc func didUpdateLocation(_ notification: Notification) {
        guard
            let data = notification.userInfo as? [String: CLLocation],
            let location = data["location"]
        else {return}
        self.location = location
    }
    
}
