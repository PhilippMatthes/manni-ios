//
//  ModeChainCollectionViewCell.swift
//  manni-ios
//
//  Created by It's free real estate on 28.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB
import Material


class ModeChainCollectionViewCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "ModeChainCollectionViewCell"

    public var modeElement: Route.ModeElement? {
        didSet {
            guard let modeElement = modeElement else {return}
            
            modeNameLabel.text = modeElement.name ?? "n/a"
            modeImage.image = modeElement.mode?.icon
        }
    }
    
    public var isDestination: Bool? {
        didSet {
            if isDestination == true {
                nextChevron.alpha = 0
            } else {
                nextChevron.alpha = 1
            }
        }
    }
    
    fileprivate let skeuomorphismView = SkeuomorphismView()
    fileprivate let modeImage = UIImageView()
    fileprivate let modeNameLabel = UILabel()
    fileprivate let nextChevron = UIImageView(image: UIImage.fontAwesomeIcon(name: .chevronRight, style: .solid, textColor: Color.grey.darken4, size: .init(width: 12, height: 12)))
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    fileprivate func prepare() {        
        contentView.layout(modeImage)
            .left()
            .centerY()
            .height(32)
            .width(32)
        modeImage.tintColor = Color.grey.darken4
        
        contentView.layout(modeNameLabel)
            .after(modeImage, 4)
            .centerY()
        modeNameLabel.textColor = Color.grey.darken4
        
        contentView.layout(nextChevron)
            .after(modeNameLabel, 4)
            .right(4)
            .width(24)
            .height(24)
            .centerY()
        
        modeNameLabel.sizeToFit()
        layoutSubviews()
    }
    
}
