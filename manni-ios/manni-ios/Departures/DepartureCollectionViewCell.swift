//
//  DepartureCollectionViewCell.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB

class DepartureCollectionViewCell: UICollectionViewCell {
    public static let identifier = "DepartureCollectionViewCell"
    
    public var departure: Departure? {
        didSet {
            guard let departure = departure else {return}
            lineNameLabel.text = departure.line
            lineNameLabel.sizeToFit()
            directionLabel.text = departure.direction
            directionLabel.sizeToFit()
            skeuomorphismView.lightColor = departure.gradient.first ?? .white
            skeuomorphismView.gradient = departure.gradient
            
            if let latency = departure.manniLatency {
                latencyBadgeBackground.alpha = 1
                latencyBadgeLabel.text = latency
            } else {
                latencyBadgeBackground.alpha = 0
                latencyBadgeLabel.text = "Pünktlich"
            }
            
            updateTimeResponsiveUI()
        }
    }
        
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let lineNameLabel = UILabel()
    fileprivate let directionLabel = UILabel()
    fileprivate let etaLabel = UILabel()
    fileprivate let latencyBadgeBackground = SkeuomorphismView()
    fileprivate let latencyBadgeLabel = UILabel()
    
    fileprivate var timeResponsiveRefreshTimer: Timer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    fileprivate func prepare() {        
        contentView.layout(skeuomorphismView)
            .height(216)
            .width(148)
            .edges(top: 8, right: 8)
        skeuomorphismView.cornerRadius = 24
        skeuomorphismView.lightShadowOpacity = 0.9
        skeuomorphismView.darkShadowOpacity = 0.1
        
        skeuomorphismView.contentView.layout(lineNameLabel)
            .topLeft(top: 12, left: 12)
            .right(12)
        lineNameLabel.numberOfLines = 2
        lineNameLabel.adjustsFontSizeToFitWidth = true
        lineNameLabel.font = RobotoFont.bold(with: 38)
        lineNameLabel.textColor = .white
        
        skeuomorphismView.contentView.layout(directionLabel)
            .below(lineNameLabel, 4)
            .left(12)
            .right(12)
        directionLabel.numberOfLines = 2
        directionLabel.adjustsFontSizeToFitWidth = true
        directionLabel.font = RobotoFont.regular(with: 18)
        directionLabel.textColor = .white
        
        skeuomorphismView.contentView.layout(etaLabel)
            .left(12)
            .right(12)
            .bottom(24)
        etaLabel.font = RobotoFont.light(with: 16)
        etaLabel.textColor = .white
        etaLabel.numberOfLines = 1
        
        contentView.layout(latencyBadgeBackground)
            .right()
            .top()
        latencyBadgeBackground.cornerRadius = 8
        
        latencyBadgeBackground.contentView.layout(latencyBadgeLabel)
            .edges(top: 4, left: 8, bottom: 4, right: 8)
        latencyBadgeLabel.font = RobotoFont.bold(with: 12)
        
        timeResponsiveRefreshTimer = .scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimeResponsiveUI),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timeResponsiveRefreshTimer!, forMode: .common)
    }
    
    @objc func updateTimeResponsiveUI() {
        guard let departure = departure else {return}
        etaLabel.text = departure.manniETA
    }
    
}
