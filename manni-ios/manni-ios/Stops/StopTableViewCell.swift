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


protocol SuggestionInfoButtonDelegate {
    func didSelectSuggestionInfoButton(on stop: Stop?)
}


class StopTableViewCell: UITableViewCell {
    fileprivate let leftBorderView = SkeuomorphismView()
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let stopNameLabel = UILabel()
    fileprivate let stopLocationLabel = UILabel()
    fileprivate let suggestionBadgeView = SkeuomorphismView()
    fileprivate let suggestionBadgeLabel = UILabel()
    fileprivate let suggestionBadgeButton = SkeuomorphismIconButton(image: UIImage.fontAwesomeIcon(
        name: .info, style: .solid, textColor: Color.grey.darken3, size: .init(width: 12, height: 12)
    ))
    
    public static let reuseIdentifier = "StopTableViewCell"
    
    public var stop: Stop? {
        didSet {
            leftBorderView.lightColor = stop?.gradient.first ?? .white
            leftBorderView.gradient = stop?.gradient ?? [.white, .white]
            stopNameLabel.text = stop?.name
            stopLocationLabel.text = stop?.region ?? "Dresden"
        }
    }
    
    public var isSuggestion: Bool? {
        didSet {
            if isSuggestion == true {
                suggestionBadgeView.isHidden = false
            }
            if isSuggestion == false {
                suggestionBadgeView.isHidden = true
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
    
    public var suggestionButtonDelegate: SuggestionInfoButtonDelegate?
    
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
        layer.cornerRadius = 24
        
        contentView.layout(skeuomorphismView)
            .edges(top: 16, left: 12, bottom: 12, right: 12)
        skeuomorphismView.contentView.backgroundColor = Color.grey.lighten4
        skeuomorphismView.cornerRadius = 12
        
        contentView.layout(suggestionBadgeView)
            .right(24)
            .top(8)
        suggestionBadgeView.cornerRadius = 12
        suggestionBadgeView.lightColor = Color.grey.lighten5
        suggestionBadgeView.contentView.backgroundColor = Color.grey.lighten5
        
        suggestionBadgeView.contentView.layout(suggestionBadgeButton)
            .right()
            .top()
            .bottom()
            .height(32)
            .width(32)
        suggestionBadgeButton.skeuomorphismView.cornerRadius = 16
        suggestionBadgeButton.addTarget(self, action: #selector(didSelectSuggestionInfoButton), for: .touchUpInside)
        
        suggestionBadgeView.contentView.layout(suggestionBadgeLabel)
            .top(6)
            .bottom(6)
            .left(12)
            .before(suggestionBadgeButton, 4)
        suggestionBadgeLabel.font = RobotoFont.regular(with: 12)
        suggestionBadgeLabel.textColor = Color.grey.darken3
        suggestionBadgeLabel.text = "Vorschlag"
        
        contentView.layout(leftBorderView)
            .left(12)
            .top(16)
            .bottom(12)
            .width(12)
        leftBorderView.cornerRadius = 24
        
        contentView.layout(stopNameLabel)
            .top(32)
            .left(48)
            .right(48)
        stopNameLabel.font = RobotoFont.bold(with: 24)
        stopNameLabel.textColor = Color.grey.darken4
        stopNameLabel.numberOfLines = 0
        
        contentView.layout(stopLocationLabel)
            .below(stopNameLabel, 8)
            .left(48)
            .right(48)
            .bottom(32)
        stopLocationLabel.font = RobotoFont.light(with: 18)
        stopLocationLabel.textColor = Color.grey.darken2
        stopLocationLabel.numberOfLines = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation(_:)), name: SearchController.didUpdateLocation, object: nil)
    }
    
    @objc func didSelectSuggestionInfoButton() {
        suggestionButtonDelegate?.didSelectSuggestionInfoButton(on: stop)
    }
    
    @objc func didUpdateLocation(_ notification: Notification) {
        guard
            let data = notification.userInfo as? [String: CLLocation],
            let location = data["location"]
        else {return}
        self.location = location
    }
    
}
