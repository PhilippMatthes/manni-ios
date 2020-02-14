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
            lightColor = departure?.gradient.first ?? .white
            gradient = departure?.gradient
        }
    }
    
    public var stop: Stop? {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var tripStops: [TripStop]? {
        didSet {
            tableView.reloadData()
            scrollToCurrentStop()
        }
    }
    
    public var tableViewContentInset: UIEdgeInsets? {
        didSet {
            guard let contentInset = tableViewContentInset else {return}
            tableView.contentInset = contentInset
        }
    }
    
    fileprivate let tableView = TableView(frame: .zero, style: .grouped)
    
    override func prepare() {
        super.prepare()
        
        prepareTableView()
    }
    
}

extension TripView {
    fileprivate func prepareTableView() {
        contentView.layout(tableView)
            .edges()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = false
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 24
        tableView.register(TripTableViewCell.self, forCellReuseIdentifier: TripTableViewCell.reuseIdentifier)
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
        cell.departure = departure
        cell.stop = stop
        cell.updateTimeResponsiveUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripStops?.count ?? 0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.opacity = 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            cell.layer.opacity = 1.0
        }, completion: nil)
    }
    
    @objc func scrollToCurrentStop(animated: Bool = false) {
        guard let tripStops = tripStops else {return}
        for (i, tripStop) in tripStops.enumerated() {
            if tripStop.time.timeIntervalSinceNow >= 0 {
                tableView.scrollToRow(at: IndexPath(item: i, section: 0), at: .middle, animated: animated)
                return
            }
        }
    }
}

extension TripView: TripTableViewCellDelegate {
    func shouldScroll(to indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}
