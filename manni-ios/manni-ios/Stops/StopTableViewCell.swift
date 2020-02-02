//
//  StopTableViewCell.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB

class StopTableViewCell: UITableViewCell {
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate var stopNameLabel = UILabel()
    
    public static let reuseIdentifier = "StopTableViewCell"
    
    public var stop: Stop! {
        didSet {
            stopNameLabel.text = stop.name
        }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      prepare()
    }
    
    /**
     An initializer that initializes the object.
     - Parameter style: A UITableViewCellStyle enum.
     - Parameter reuseIdentifier: A String identifier.
     */
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
      super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
      prepare()
    }
    
    func prepare() {
        contentView.layout(skeuomorphismView)
            .edges(top: 12, left: 12, bottom: 12, right: 12)
            .height(200)
        skeuomorphismView.contentView.backgroundColor = Color.grey.lighten4
        backgroundColor = .clear
    }
    
}
