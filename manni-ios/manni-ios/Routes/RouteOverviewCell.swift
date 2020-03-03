//
//  RouteOverviewCell.swift
//  manni-ios
//
//  Created by It's free real estate on 27.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import DVB


protocol RouteOverviewCellDelegate {
    func didSelect(route: Route)
}


class RouteOverviewCell: UITableViewCell {
    
    public static let reuseIdentifier = "RouteOverviewCell"
    
    public var delegate: RouteOverviewCellDelegate?
    
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let departureView = UIView()
    fileprivate let departureETALabel = UILabel()
    fileprivate let travelTimeLabel = UILabel()
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate let collectionView = CollectionView()
    
    private var route: Route?
    private var timeResponsiveRefreshTimer: Timer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    public func prepare(for route: Route?) {
        self.route = route
        if let route = route {
            travelTimeLabel.text = "\(route.duration) min"
            departureETALabel.text = "\(route.manniDepartureETA) - \(route.manniArrivalETA)"
            skeuomorphismView.contentView.isLoading = false
        } else {
            travelTimeLabel.text = " "
            departureETALabel.text = " "
            skeuomorphismView.contentView.isLoading = true
        }
        collectionView.reloadData()
    }
    
    fileprivate func prepare() {
        selectionStyle = .none
        backgroundColor = .clear
        
        prepareTravelChainCollectionView()
        
        contentView.layout(skeuomorphismView)
            .edges(top: 4, left: 4, bottom: 4, right: 4)
        skeuomorphismView.cornerRadius = 30
        
        skeuomorphismView.contentView.layout(departureView)
            .top(16)
            .height(16)
            .left(20)
            .right(20)
        
        departureView.layout(departureETALabel)
            .left()
            .width(128)
            .top()
            .bottom()
        departureETALabel.font = RobotoFont.regular(with: 16)
        departureETALabel.clipsToBounds = true
        departureETALabel.layer.cornerRadius = 4
        
        departureView.layout(travelTimeLabel)
            .width(128)
            .right()
            .top()
            .bottom()
        travelTimeLabel.font = RobotoFont.regular(with: 16)
        travelTimeLabel.textAlignment = .right
        travelTimeLabel.clipsToBounds = true
        travelTimeLabel.layer.cornerRadius = 4
        travelTimeLabel.textColor = Color.grey.base
                
        skeuomorphismView.contentView.layout(collectionView)
            .height(64)
            .left()
            .right()
            .bottom()
        
        skeuomorphismView.contentView.fakedViews = [
            departureETALabel,
            travelTimeLabel,
        ]
    }
    
}

extension RouteOverviewCell {
    func prepareTravelChainCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ModeChainCollectionViewCell.self, forCellWithReuseIdentifier: ModeChainCollectionViewCell.reuseIdentifier)
        
        flowLayout.estimatedItemSize = .init(width: 128, height: 56)
        flowLayout.scrollDirection = .horizontal
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = flowLayout
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCollectionView)))
    }
    
    @objc func didTapCollectionView() {
        guard let route = route else {return}
        delegate?.didSelect(route: route)
    }
}

extension RouteOverviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModeChainCollectionViewCell.reuseIdentifier, for: indexPath) as! ModeChainCollectionViewCell
        guard let route = route else {return cell}
        cell.modeElement = route.modeChain[indexPath.row]
        cell.isDestination = indexPath.row == max(0, route.modeChain.count - 1)
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return route?.modeChain.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let route = route else {return}
        delegate?.didSelect(route: route)
    }
}
