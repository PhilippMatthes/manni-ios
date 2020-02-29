//
//  RoutesOverlayController.swift
//  manni-ios
//
//  Created by It's free real estate on 27.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import DVB


protocol RoutesOverlayControllerDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollView(
        _ scrollView: UIScrollView,
        willEndScrollingWithVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    )
}


class RoutesOverlayController: ViewController {
    
    public var routes: [Route]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    public weak var delegate: RoutesOverlayControllerDelegate?
    
    private(set) lazy var tableView = UITableView()
    
    override func loadView() {
        view = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RouteOverViewCell.self, forCellReuseIdentifier: RouteOverViewCell.reuseIdentifier)
    }
    
}

extension RoutesOverlayController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        delegate?.scrollView(
            scrollView,
            willEndScrollingWithVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RouteOverViewCell.reuseIdentifier, for: indexPath) as! RouteOverViewCell
        cell.route = routes?[indexPath.row]
        return cell
    }
}
