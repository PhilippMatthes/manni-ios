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
    class Cell: TableViewCell {
        fileprivate let horizontalPadding: CGFloat = 24
        fileprivate let verticalPadding: CGFloat = 12
        fileprivate let barWidth: CGFloat = 4
        
        public class var reuseIdentifier: String {
            get {
                return "RouteDetail.Cell"
            }
        }
        
        public func prepare(for detail: RouteDetail) {}
    }
    
    public var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}


class RouteArrival: RouteDetail {
    public let arrivalTime: Date
    
    init(arrivalTime: Date) {
        self.arrivalTime = arrivalTime
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let bar = UIView()
        fileprivate let arrivalLabel = UILabel()

        override class var reuseIdentifier: String {
            get {
                return "RouteArrival.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RouteArrival else {return}
            arrivalLabel.text = "Ankunft: \(detail.arrivalTime.etaString)"
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(bar)
                .left(horizontalPadding)
                .width(barWidth)
                .top()
                .bottom()
            bar.backgroundColor = Color.grey.lighten2
            
            contentView.layout(arrivalLabel)
                .after(bar, horizontalPadding)
                .right(horizontalPadding)
                .top()
                .bottom()
            arrivalLabel.font = RobotoFont.light(with: 12)
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}


class RouteDeparture: RouteDetail {
    public let departureTime: Date
    
    init(departureTime: Date) {
        self.departureTime = departureTime
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let bar = UIView()
        fileprivate let departureLabel = UILabel()
        
        override class var reuseIdentifier: String {
            get {
                return "RouteDeparture.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RouteDeparture else {return}
            departureLabel.text = "Abfahrt: \(detail.departureTime.etaString)"
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(bar)
                .left(horizontalPadding)
                .width(barWidth)
                .top()
                .bottom()
            bar.backgroundColor = Color.grey.lighten2
            
            contentView.layout(departureLabel)
                .after(bar, horizontalPadding)
                .right(horizontalPadding)
                .top()
                .bottom()
            departureLabel.font = RobotoFont.light(with: 12)
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}


class RouteKeyStop: RouteDetail {
    public let routeStop: Route.RouteStop
    
    init(routeStop: Route.RouteStop) {
        self.routeStop = routeStop
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let pointView = UIView()
        fileprivate let stopNameLabel = UILabel()
        fileprivate let platformLabel = UILabel()
        
        override class var reuseIdentifier: String {
            get {
                return "RouteKeyStop.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RouteKeyStop else {return}
            stopNameLabel.text = detail.routeStop.name
            platformLabel.text = "Plattform: \(detail.routeStop.platform?.name ?? "n/a")"
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(pointView)
                .left(horizontalPadding)
                .centerY()
                .width(12)
                .height(12)
            pointView.layer.cornerRadius = 6
            pointView.backgroundColor = Color.blue.accent4
            
            contentView.layout(stopNameLabel)
                .after(pointView, horizontalPadding)
                .right(horizontalPadding)
                .top(verticalPadding)
            stopNameLabel.font = RobotoFont.bold(with: 18)
            
            contentView.layout(platformLabel)
                .after(pointView, horizontalPadding)
                .right(horizontalPadding)
                .below(stopNameLabel, 4)
                .bottom(verticalPadding)
            platformLabel.font = RobotoFont.light(with: 12)
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}


class RoutePassedByStop: RouteDetail {
    public let routeStop: Route.RouteStop
    
    init(routeStop: Route.RouteStop) {
        self.routeStop = routeStop
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let bar = UIView()
        fileprivate let pointView = UIView()
        fileprivate let stopNameLabel = UILabel()
        
        override class var reuseIdentifier: String {
            get {
                return "RoutePassedByStop.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RoutePassedByStop else {return}
            stopNameLabel.text = detail.routeStop.name
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(bar)
                .left(horizontalPadding)
                .width(barWidth)
                .top()
                .bottom()
            bar.backgroundColor = Color.grey.lighten2
            
            contentView.layout(pointView)
                .left(horizontalPadding - barWidth / 2)
                .centerY()
                .width(12)
                .height(12)
            pointView.layer.cornerRadius = 3
            pointView.backgroundColor = Color.grey.lighten2
            
            contentView.layout(stopNameLabel)
                .after(pointView, horizontalPadding)
                .right(horizontalPadding)
                .top(verticalPadding)
                .bottom(verticalPadding)
            stopNameLabel.font = RobotoFont.light(with: 12)
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}


class RouteStairsTransition: RouteDetail {
    enum Direction {
        case up, down
    }
    
    public let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    class Cell: RouteDetail.Cell {
        fileprivate let iconView = UIImageView()
        fileprivate let informationLabel = UILabel()
        
        override class var reuseIdentifier: String {
            get {
                return "RouteStairsTransition.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RouteStairsTransition else {return}
            switch detail.direction {
            case .up:
                iconView.image =  UIImage.fontAwesomeIcon(
                    name: .sortAmountUpAlt,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 32, height: 32)
                ).withRenderingMode(.alwaysTemplate)
                informationLabel.text = "Treppen aufwärts"
            case .down:
                iconView.image =  UIImage.fontAwesomeIcon(
                    name: .sortAmountDownAlt,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 32, height: 32)
                ).withRenderingMode(.alwaysTemplate)
                informationLabel.text = "Treppen abwärts"
            }
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(iconView)
                .left(horizontalPadding)
                .height(48)
                .width(48)
                .top(verticalPadding)
                .bottom(verticalPadding)
            
            contentView.layout(informationLabel)
                .after(iconView, horizontalPadding)
                .top(verticalPadding)
                .bottom(verticalPadding)
                .right(horizontalPadding)
            
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}

