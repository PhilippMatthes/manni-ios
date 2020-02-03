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
            lineNameLabel.text = departure?.line
            lineNameLabel.textColor = departure?.color
            directionLabel.text = departure?.direction
            directionLabel.textColor = departure?.color
            updateTimeResponsiveUI()
        }
    }
    
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let lineNameLabel = UILabel()
    fileprivate let directionLabel = UILabel()
    fileprivate let etaLabel = UILabel()
    
    fileprivate var timer: Timer?
    
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
            .height(188)
            .width(148)
            .edges()
        skeuomorphismView.contentView.backgroundColor = Color.grey.lighten4
        
        skeuomorphismView.contentView.layout(lineNameLabel)
            .topLeft(top: 12, left: 12)
            .right(12)
        lineNameLabel.font = RobotoFont.bold(with: 48)
        
        skeuomorphismView.contentView.layout(directionLabel)
            .below(lineNameLabel, 4)
            .left(12)
            .right(12)
        directionLabel.numberOfLines = 2
        directionLabel.font = RobotoFont.light(with: 18)
        
        skeuomorphismView.contentView.layout(etaLabel)
            .left(12)
            .right(12)
            .bottom(24)
        etaLabel.font = RobotoFont.light(with: 18)
        
        timer = .scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimeResponsiveUI),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateTimeResponsiveUI() {
        guard let departure = departure else {return}
        etaLabel.text = departure.localizedETA(for: .init(identifier: "de"))
    }
    
}
