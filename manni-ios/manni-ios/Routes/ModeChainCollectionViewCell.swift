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
            if modeElement.mode == Mode.footpath {
                modeNameLabelBackground.alpha = 0
                modeNameLabel.text = nil
                modeDirectionLabel.text = nil
            } else {
                modeNameLabelBackground.alpha = 1
                modeNameLabelBackground.gradient = modeElement.gradient
                modeNameLabel.text = modeElement.name
                modeDirectionLabel.text = modeElement.direction
            }
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
    
    fileprivate let modeImage = UIImageView()
    fileprivate let modeNameLabelBackground = SkeuomorphismView()
    fileprivate let modeNameLabel = UILabel()
    fileprivate let modeDirectionLabel = UILabel()
    fileprivate let nextChevron = UIImageView(
        image: UIImage.fontAwesomeIcon(
            name: .chevronRight,
            style: .solid,
            textColor: .white,
            size: .init(width: 12, height: 12)
        ).withRenderingMode(.alwaysTemplate)
    )
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    fileprivate func prepare() {
        
        layer.cornerRadius = 32
        
        contentView.layout(modeImage)
            .left()
            .centerY()
            .height(32)
            .width(32)
        modeImage.tintColor = Color.grey.base
        
        contentView.layout(modeNameLabelBackground)
            .after(modeImage, 4)
            .centerY()
            .height(32)
        modeNameLabelBackground.cornerRadius = 8
        
        modeNameLabelBackground.contentView.layout(modeNameLabel)
            .left(8)
            .top(4)
            .bottom(4)
        modeNameLabel.font = RobotoFont.bold(with: 16)
        modeNameLabel.textColor = .white
        
        modeNameLabelBackground.contentView.layout(modeDirectionLabel)
            .after(modeNameLabel, 4)
            .top(4)
            .bottom(4)
            .right(8)
        modeDirectionLabel.font = RobotoFont.regular(with: 16)
        modeDirectionLabel.textColor = .white
        
        contentView.layout(nextChevron)
            .after(modeNameLabelBackground, 12)
            .right()
            .width(16)
            .height(16)
            .centerY()
        nextChevron.tintColor = Color.grey.base
        
    }
    
}
