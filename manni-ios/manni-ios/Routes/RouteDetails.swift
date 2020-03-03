//
//  RouteDetails.swift
//  manni-ios
//
//  Created by It's free real estate on 02.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//


import Foundation
import Material
import DVB


class RouteDetail {
    public var position: Position?
    
    public var cellType: RouteDetail.Cell.Type {
        return Cell.self
    }
    
    enum Position {
        case top, bottom
    }
    
    class Cell: TableViewCell {
        fileprivate let upperDotView = UIView()
        fileprivate let lowerDotView = UIView()
        fileprivate let innerView = UIView()
        fileprivate let separatorView = UIView()
        
        public class var reuseIdentifier: String {
            return "RouteDetail.Cell"
        }
        
        override func prepare() {
            super.prepare()
            contentView.layout(separatorView)
                .bottom()
                .right()
                .left(58)
                .height(1)
            separatorView.backgroundColor = Color.grey.lighten3
            
            contentView.layout(upperDotView)
                .left(24)
                .top(4)
                .width(8)
                .height(8)
            upperDotView.backgroundColor = Color.grey.base
            upperDotView.layer.cornerRadius = 4
            
            contentView.layout(innerView)
                .below(upperDotView, 4)
                .left()
                .right()
            
            contentView.layout(lowerDotView)
                .below(innerView, 4)
                .left(24)
                .bottom(4)
                .width(8)
                .height(8)
            lowerDotView.backgroundColor = Color.grey.base
            lowerDotView.layer.cornerRadius = 4
        }
        
        public func prepare(for detail: RouteDetail) {
            switch detail.position {
            case .top:
                upperDotView.isHidden = true
                lowerDotView.isHidden = false
            case .bottom:
                upperDotView.isHidden = false
                lowerDotView.isHidden = true
            case .none:
                upperDotView.isHidden = false
                lowerDotView.isHidden = false
            }
        }
    }
}


class RouteByFoot: RouteDetail {
    public let icon: UIImage
    public let text: String
    
    init(icon: UIImage, text: String) {
        self.icon = icon
        self.text = text
    }
    
    override var cellType: RouteDetail.Cell.Type {
        return Cell.self
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let icon = UIImageView()
        fileprivate let label = UILabel()
        
        override func prepare(for detail: RouteDetail) {
            super.prepare(for: detail)
            
            guard let detail = detail as? RouteByFoot else {return}
            icon.image = detail.icon
            label.text = detail.text
        }
        
        override func prepare() {
            super.prepare()
            
            innerView.layout(icon)
                .left(16)
                .width(24)
                .height(24)
                .top(4)
                .bottom(4)
            icon.tintColor = Color.grey.base
            
            innerView.layout(label)
                .after(label, 24)
                .centerY()
                .right(24)
            label.font = RobotoFont.bold(with: 16)
            label.textColor = Color.grey.base
        }
        
        override class var reuseIdentifier: String {
            return "RouteByFoot.Cell"
        }
    }
}


class RouteWalk: RouteByFoot {
    init(walkDuration: Int?) {
        let text = walkDuration == nil ? "Fußweg" : "\(walkDuration!) min Fußweg"
        let icon = UIImage.fontAwesomeIcon(
            name: .walking,
            style: .solid,
            textColor: .white,
            size: .init(width: 24, height: 24)
        ).withRenderingMode(.alwaysTemplate)
        super.init(icon: icon, text: text)
    }
}


class RouteStairsUp: RouteByFoot {
    init() {
        let text = "Treppensteigen aufwärts"
        let icon = UIImage.fontAwesomeIcon(
            name: .sortAmountUpAlt,
            style: .solid,
            textColor: .white,
            size: .init(width: 24, height: 24)
        ).withRenderingMode(.alwaysTemplate)
        super.init(icon: icon, text: text)
    }
}


class RouteStairsDown: RouteByFoot {
    init() {
        let text = "Treppensteigen abwärts"
        let icon = UIImage.fontAwesomeIcon(
            name: .sortAmountDownAlt,
            style: .solid,
            textColor: .white,
            size: .init(width: 24, height: 24)
        ).withRenderingMode(.alwaysTemplate)
        super.init(icon: icon, text: text)
    }
}


class RouteTransit: RouteDetail {
    public let regularStops: [Route.RouteStop]
    public let modeElement: Route.ModeElement
    
    init(regularStops: [Route.RouteStop], modeElement: Route.ModeElement) {
        self.regularStops = regularStops
        self.modeElement = modeElement
        super.init()
    }
    
    override var cellType: RouteDetail.Cell.Type {
        return Cell.self
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let bar = SkeuomorphismView()
        fileprivate let originDotView = UIView()
        fileprivate let destinationDotView = UIView()
        fileprivate let originStopNameLabel = UILabel()
        fileprivate let originDepartureTimeLabel = UILabel()
        fileprivate let destinationStopNameLabel = UILabel()
        fileprivate let destinationArrivalTimeLabel = UILabel()
        fileprivate let modeNameLabelBackground = SkeuomorphismView()
        fileprivate let modeNameLabel = UILabel()
        fileprivate let modeDirectionLabel = UILabel()
        fileprivate let stopsBetweenLabel = UILabel()
        
        override func prepare(for detail: RouteDetail) {
            super.prepare(for: detail)
            
            guard let detail = detail as? RouteTransit else {return}
            bar.gradient = detail.modeElement.gradient
            originStopNameLabel.text = detail.regularStops.first?.name
            originDepartureTimeLabel.text = detail.regularStops.first?.departureTime.shortETAString
            destinationStopNameLabel.text = detail.regularStops.last?.name
            destinationArrivalTimeLabel.text = detail.regularStops.last?.arrivalTime.shortETAString
            modeNameLabelBackground.gradient = detail.modeElement.gradient
            modeNameLabel.text = detail.modeElement.name
            modeDirectionLabel.text = detail.modeElement.direction
            
            if detail.regularStops.count > 2 {
                stopsBetweenLabel.text = "\(detail.regularStops.count - 2) Zwischenstopps"
            } else {
                stopsBetweenLabel.text = "Direkter Transfer"
            }
        }
        
        override func prepare() {
            super.prepare()
            innerView.layout(bar)
                .left(22)
                .width(12)
                .top(4)
                .bottom(4)
            bar.cornerRadius = 6
            
            innerView.layout(originDotView)
                .left(24)
                .top(6)
                .width(8)
                .height(8)
            originDotView.layer.cornerRadius = 4
            originDotView.backgroundColor = .white
            
            innerView.layout(destinationDotView)
                .left(24)
                .bottom(6)
                .width(8)
                .height(8)
            destinationDotView.layer.cornerRadius = 4
            destinationDotView.backgroundColor = .white
            
            innerView.layout(originStopNameLabel)
                .top(4)
                .after(bar, 24)
            originStopNameLabel.font = RobotoFont.bold(with: 16)
            
            innerView.layout(originDepartureTimeLabel)
                .top(4)
                .after(originStopNameLabel, 8)
                .right(24)
            originDepartureTimeLabel.font = RobotoFont.regular(with: 16)
            originDepartureTimeLabel.textColor = Color.grey.base
            originDepartureTimeLabel.textAlignment = .right
            
            innerView.layout(modeNameLabelBackground)
                .below(originStopNameLabel, 8)
                .after(bar, 24)
                .height(32)
            modeNameLabelBackground.cornerRadius = 8
            
            modeNameLabelBackground.contentView.layout(modeNameLabel)
                .left(8)
                .top(4)
                .bottom(4)
            modeNameLabel.font = RobotoFont.bold(with: 16)
            modeNameLabel.textColor = .white
            
            modeNameLabelBackground.contentView.layout(modeDirectionLabel)
                .after(modeNameLabel, 4)
                .top(4)
                .bottom(4)
                .right(8)
            modeDirectionLabel.font = RobotoFont.regular(with: 16)
            modeDirectionLabel.textColor = .white
            
            innerView.layout(stopsBetweenLabel)
                .below(modeNameLabelBackground, 64)
                .after(bar, 24)
                .right(24)
            stopsBetweenLabel.font = RobotoFont.regular(with: 16)
            stopsBetweenLabel.textColor = Color.grey.base
            
            innerView.layout(destinationStopNameLabel)
                .below(stopsBetweenLabel, 4)
                .after(bar, 24)
                .bottom(4)
            destinationStopNameLabel.font = RobotoFont.bold(with: 16)
            
            innerView.layout(destinationArrivalTimeLabel)
                .below(stopsBetweenLabel, 4)
                .after(destinationStopNameLabel, 24)
                .right(24)
                .bottom(4)
            destinationArrivalTimeLabel.font = RobotoFont.regular(with: 16)
            destinationArrivalTimeLabel.textColor = Color.grey.base
            destinationArrivalTimeLabel.textAlignment = .right
        }
        
        override class var reuseIdentifier: String {
            return "RouteTransit.Cell"
        }
    }
}

