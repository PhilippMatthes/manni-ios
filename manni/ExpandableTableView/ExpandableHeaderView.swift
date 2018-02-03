//
//  ExpandableHeaderView.swift
//  manni
//
//  Created by Philipp Matthes on 03.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import DVB
import Material
import Motion

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int?
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lowerLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    @objc func selectHeaderView(gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as? ExpandableHeaderView, let section = cell.section else {return}
        delegate?.toggleSection(header: self, section: section)
    }
    
    func configure(routeSection: RouteSection, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.section = section; self.delegate = delegate
        
        upperLabel.text = "\(routeSection.route.duration) min - \(routeSection.route.interchanges) Umstiege"
        lowerLabel.text = "\(routeSection.route.partialRoutes.first!.regularStops!.first!.departureTime.time()) - \(routeSection.route.partialRoutes.last!.regularStops!.last!.departureTime.time())"
        
        bgView.blur()
        
        var offset = 0
        if scrollView.layer.sublayers == nil {
            scrollView.contentSize = CGSize(width: 2*58*CGFloat(routeSection.route.partialRoutes.count), height: scrollView.frame.height)
            for i in 0..<routeSection.route.partialRoutes.count {
                if let lineName = routeSection.route.partialRoutes[i].mode.name {
                    let buttonFrame = CGRect(x: 8+offset*58, y: 0, width: 50, height: 50)
                    let button = UIView(frame: buttonFrame)
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                    
                    label.text = lineName
                    
                    button.layer.cornerRadius = 5.0
                    
                    label.textColor = UIColor.white
                    label.textAlignment = .center
                    label.font = label.font.withSize(17)
                    
                    var color: UIColor
                    if let lineNumber = Int(lineName) {
                        color = Colors.color(forInt: lineNumber)
                    } else {
                        color = Colors.color(forInt: lineName.count)
                    }
                    button.backgroundColor = color
                    
                    self.scrollView.addSubview(button)
                    
                    button.addSubview(label)
                    
                    offset += 1
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Design
    }
    
}
