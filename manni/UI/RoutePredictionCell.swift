//
//  RoutePredictionCell.swift
//  manni
//
//  Created by Philipp Matthes on 06.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import Motion

class RoutePredictionCell: TableViewCell {
    
    static let height: CGFloat = 100
    static let identifier: String = "routePredictionCell"
        
    @IBOutlet weak var designView: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUp(forStart start: String, end: String) {
        fromLabel.text = start
        toLabel.text = end
        fromLabel.textColor = .white
        toLabel.textColor = .white
        designView.layer.cornerRadius = 4
        let color = Colors.color(forInt: "\(start)\(end)".count)
        backgroundColor = color
        pulseColor = color.lighter(by: 15)!
    }
}
