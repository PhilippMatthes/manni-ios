//
//  GPSView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 04.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material


class GPSView: SkeuomorphismView {
    
    fileprivate let startImageView = UIImageView()
    fileprivate let animatingImageView = UIImageView()
    fileprivate let pullIcon = UIImageView(image: Icon.arrowDownward)
    
    override func prepare() {
        super.prepare()
        animatingImageView.animationImages = (0...119).map {
            UIImage(named: "satellit\($0).png")!
        }
        animatingImageView.animationDuration = 4
        
        startImageView.image = UIImage(named: "satellit0.png")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor(patternImage: UIImage(named: "stars")!)
        
        for imageView in [startImageView, animatingImageView] {
            contentView.layout(imageView)
                .bottom(40)
                .centerX()
                .height(128)
                .width(128)
        }
        
        contentView.layout(pullIcon)
            .bottom(4)
            .centerX()
            .height(32)
            .width(32)
        pullIcon.tintColor = Color.white
    }
    
    public func startAnimating() {
        startImageView.alpha = 0.0
        animatingImageView.startAnimating()
    }
    
    public func stopAnimating() {
        startImageView.alpha = 1.0
        animatingImageView.stopAnimating()
    }
    
}
