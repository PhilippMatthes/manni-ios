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
        fileprivate let arrivalBar = UIView()
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
            
            contentView.layout(arrivalBar)
                .left(horizontalPadding)
                .width(barWidth)
                .top()
                .bottom()
            arrivalBar.backgroundColor = Color.blue.accent4
            
            contentView.layout(arrivalLabel)
                .after(arrivalBar, horizontalPadding)
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
        fileprivate let departureBar = UIView()
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
            
            contentView.layout(departureBar)
                .left(horizontalPadding)
                .width(barWidth)
                .top()
                .bottom()
            departureBar.backgroundColor = Color.blue.accent4
            
            contentView.layout(departureLabel)
                .after(departureBar, horizontalPadding)
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
        
        override class var reuseIdentifier: String {
            get {
                return "RouteKeyStop.Cell"
            }
        }
        
        override func prepare(for detail: RouteDetail) {
            guard let detail = detail as? RouteKeyStop else {return}
            stopNameLabel.text = detail.routeStop.name
        }
        
        override func prepare() {
            super.prepare()
            
            contentView.layout(pointView)
                .left(horizontalPadding)
                .width(12)
                .height(12)
            pointView.layer.cornerRadius = 6
            
            contentView.layout(stopNameLabel)
                .after(pointView, horizontalPadding)
                .right(horizontalPadding)
                .top()
                .bottom()
            stopNameLabel.font = RobotoFont.bold(with: 12)
        }
    }
    
    override var cellType: RouteDetail.Cell.Type {
        get {
            return Cell.self
        }
    }
}

