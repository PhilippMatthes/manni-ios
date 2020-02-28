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


class RouteOverViewCell: UITableViewCell {
    
    public static let reuseIdentifier = "RouteOverViewCell"
    
    public var route: Route? {
        didSet {
            guard let route = route else {return}
            
            travelTimeLabel.text = "Fahrtzeit: \(route.duration) min"
            collectionView.reloadData()
            
            updateTimeResponsiveUI()
        }
    }
    
    fileprivate let departureView = UIView()
    fileprivate let departureOnLabel = UILabel()
    fileprivate let departureETALabel = UILabel()
    fileprivate let travelView = UIView()
    fileprivate let travelTimeLabel = UILabel()
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate let collectionView = CollectionView()
    
    private var timeResponsiveRefreshTimer: Timer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    fileprivate func prepare() {
        backgroundColor = Color.grey.darken4
        
        prepareTimeResponsiveUI()
        prepareTravelChainCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(collectionView)
            .edges()
    }
    
    @objc func updateTimeResponsiveUI() {
        guard let route = route else {return}
        departureETALabel.text = route.manniETA
    }
    
}

extension RouteOverViewCell {
    func prepareTimeResponsiveUI() {
        timeResponsiveRefreshTimer = .scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimeResponsiveUI),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timeResponsiveRefreshTimer!, forMode: .common)
    }
    
    func prepareTravelChainCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ModeChainCollectionViewCell.self, forCellWithReuseIdentifier: ModeChainCollectionViewCell.reuseIdentifier)
        
        flowLayout.estimatedItemSize = .init(width: 128, height: 32)
        flowLayout.scrollDirection = .horizontal
        collectionView.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = flowLayout
    }
}

extension RouteOverViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ModeChainCollectionViewCell.reuseIdentifier, for: indexPath) as! ModeChainCollectionViewCell
        guard let route = route else {return cell}
        cell.modeElement = route.modeChain[indexPath.row]
        cell.isDestination = indexPath.row == route.modeChain.count
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return route?.modeChain.count ?? 0
    }
}
