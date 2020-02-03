//
//  DeparturesController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material

class DeparturesController: ViewController {
    
    public var stop: Stop? {
        didSet {
            loadDepartures()
        }
    }
    
    fileprivate var departures = [Departure]()
    fileprivate var scheduledTimer: Timer?
    
    fileprivate let stopNameLabel = UILabel()
    fileprivate let collectionView = CollectionView()
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    @objc func loadDepartures() {
        guard let stop = stop else {return}
        Departure.monitor(stopWithId: stop.id) {
            result in
            guard let success = result.success else {return}
            self.departures = success.departures
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            // Schedule next departure load
            self.scheduledTimer?.invalidate()
            self.scheduledTimer = Timer(fireAt: success.expirationTime, interval: 0, target: self, selector: #selector(self.loadDepartures), userInfo: nil, repeats: false)
            RunLoop.main.add(self.scheduledTimer!, forMode: .common)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layout(stopNameLabel)
            .topSafe(24)
            .left(24)
            .right(24)
        stopNameLabel.font = RobotoFont.bold(with: 24)
        stopNameLabel.textColor = Color.grey.darken4
        stopNameLabel.text = stop?.name
        if let stop = stop {
            stopNameLabel.motionIdentifier = "stopNameLabel_\(stop.id)"
        }
        
        view.layout(collectionView)
            .below(stopNameLabel, 12)
            .left(0)
            .right(0)
            .height(238)
        flowLayout.estimatedItemSize = .init(width: 148, height: 188)
        flowLayout.scrollDirection = .horizontal
        collectionView.contentInset = .init(top: 0, left: 24, bottom: 0, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(DepartureCollectionViewCell.self, forCellWithReuseIdentifier: DepartureCollectionViewCell.identifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scheduledTimer?.invalidate()
    }
    
}

extension DeparturesController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return departures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DepartureCollectionViewCell.identifier, for: indexPath) as! DepartureCollectionViewCell
        cell.departure = departures[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.opacity = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            cell.layer.opacity = 1.0
        })
    }
}
