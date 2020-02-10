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
    
    public var tripStops: [TripStop]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate let tableView = TableView()
    
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
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 24
        tableView.isUserInteractionEnabled = false
        tableView.register(TripTableViewCell.self, forCellReuseIdentifier: TripTableViewCell.reuseIdentifier)
    }
}

extension TripView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.reuseIdentifier, for: indexPath) as! TripTableViewCell
        if indexPath.row > 0 {
            cell.previousTripStop = tripStops![indexPath.row - 1]
        }
        cell.tripStop = tripStops![indexPath.row]
        if indexPath.row < tripStops!.count - 1 {
            cell.nextTripStop = tripStops![indexPath.row + 1]
        }
        cell.updateTimeResponsiveUI()
        cell.indexPath = indexPath
        cell.delegate = self
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
