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
                .withRenderingMode(.alwaysTemplate)
            modeImage.tintColor = .white
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
    fileprivate let modeNameLabel = UILabel()
    fileprivate let nextChevron = UIImageView(image: UIImage.fontAwesomeIcon(name: .chevronRight, style: .solid, textColor: .white, size: .init(width: 12, height: 12)))
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    fileprivate func prepare() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout(modeImage)
            .left()
            .centerY()
            .height(32)
            .width(32)
        
        layout(modeNameLabel)
            .after(modeImage, 8)
            .centerY()
            .width(32)
        modeNameLabel.textColor = .white
        
        layout(nextChevron)
            .after(modeNameLabel, 8)
            .right(8)
            .width(24)
            .height(24)
            .centerY()
    }
    
}
