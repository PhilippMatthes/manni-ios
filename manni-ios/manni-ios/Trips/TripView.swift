//
//  TripView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 10.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB


class TripView: SkeuomorphismView {
    
    public var departure: Departure? {
        didSet {
            departureLineLabel.text = departure?.line
            departureDirectionLabel.text = departure?.direction
            lightColor = departure?.gradient.first ?? .white
            gradient = departure?.gradient
        }
    }
    public var tripStops: [TripStop]? {
        didSet {
            tableView.reloadData()
            guard let tripStops = tripStops else {return}
            for (i, tripStop) in tripStops.enumerated() {
                if tripStop.time.timeIntervalSinceNow >= 0 {
                    tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .middle, animated: false)
                    return
                }
            }
        }
    }
    
    fileprivate let departureBackground = UIVisualEffectView()
    fileprivate let departureLineLabel = UILabel()
    fileprivate let departureDirectionLabel = UILabel()
    
    fileprivate let tableView = TableView()
    
    override func prepare() {
        super.prepare()
        
        prepareTableView()
        prepareDepartureView()
    }
    
}

extension TripView {
    fileprivate func prepareTableView() {
        contentView.layout(tableView)
            .edges()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 24
        tableView.isUserInteractionEnabled = false
        tableView.register(TripTableViewCell.self, forCellReuseIdentifier: TripTableViewCell.reuseIdentifier)
    }
    
    fileprivate func prepareDepartureView() {
        contentView.layout(departureBackground)
            .bottom()
            .left()
            .right()
        departureBackground.effect = UIBlurEffect(style: .light)
        departureBackground.clipsToBounds = true
        departureBackground.layer.cornerRadius = 32.0
        
        departureBackground.contentView.layout(departureLineLabel)
            .top(24)
            .left(24)
            .right(24)
        departureLineLabel.textColor = .white
        departureLineLabel.font = RobotoFont.bold(with: 24)
        
        departureBackground.contentView.layout(departureDirectionLabel)
            .below(departureLineLabel, 8)
            .left(24)
            .right(24)
            .bottomSafe(24)
        departureDirectionLabel.textColor = .white
        departureDirectionLabel.font = RobotoFont.regular(with: 16)
    }
}

extension TripView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.reuseIdentifier, for: indexPath) as! TripTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        if indexPath.row > 0 {
            cell.previousTripStop = tripStops![indexPath.row - 1]
        }
        cell.tripStop = tripStops![indexPath.row]
        if indexPath.row < tripStops!.count - 1 {
            cell.nextTripStop = tripStops![indexPath.row + 1]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripStops?.count ?? 0
    }
}

extension TripView: TripTableViewCellDelegate {
    func shouldScroll(to indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}
