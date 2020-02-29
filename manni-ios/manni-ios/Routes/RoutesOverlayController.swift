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
    func didSelect(route: Route)
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
    
    private(set) lazy var tableView = TableView()
    
    override func loadView() {
        view = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RouteOverviewCell.self, forCellReuseIdentifier: RouteOverviewCell.reuseIdentifier)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RouteOverviewCell.reuseIdentifier, for: indexPath) as! RouteOverviewCell
        cell.route = routes?[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let route = routes?[indexPath.row] else {return}
        didSelect(route: route)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.opacity = 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            cell.layer.opacity = 1.0
        }, completion: nil)
    }
}

extension RoutesOverlayController: RouteOverviewCellDelegate {    
    func didSelect(route: Route) {
        guard
            let routes = routes,
            let index = routes.firstIndex(of: route)
        else {return}
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        
        delegate?.didSelect(route: route)
    }
}
