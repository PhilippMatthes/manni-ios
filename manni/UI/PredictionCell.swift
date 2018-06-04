//
//  PredictionCell.swift
//  manni
//
//  Created by Philipp Matthes on 04.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import Material

class PredicitonCell: TableViewCell {
    static let height: CGFloat = 25
    static let identifier = "PredictionCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    
    func prepare(forDate date: Date) {
        let predictions = Predictor.loadPredictions(forDate: date)
        let text = predictions.first?.query ?? Config.noPrediction
        label.text = text
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        dateLabel.text = formatter.string(from: date)
        dateLabel.textColor = .white
        label.textColor = .white
        contentView.backgroundColor = Colors.color(forInt: text.count)
    }
}
