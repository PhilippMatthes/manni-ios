//
//  GPSView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 04.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material


class GPSView: SkeuomorphismView {
    
    fileprivate var images = [UIImage]()
    fileprivate let animatingImageView = UIImageView()
    fileprivate let pullIcon = UIImageView(image: Icon.arrowDownward)
    
    override func prepare() {
        super.prepare()
        
        for i in 0...119 {
            guard let image = UIImage(named: "satellit\(i).png") else {
                fatalError()
            }
            images.append(image)
        }
        animatingImageView.animationImages = images
        animatingImageView.animationDuration = 4
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor(patternImage: UIImage(named: "stars")!)
        
        contentView.layout(animatingImageView)
            .bottom(40)
            .centerX()
            .height(128)
            .width(128)
        
        contentView.layout(pullIcon)
            .bottom(4)
            .centerX()
            .height(32)
            .width(32)
        pullIcon.tintColor = Color.white
    }
    
    public func startAnimating() {
        animatingImageView.startAnimating()
    }
    
    public func stopAnimating() {
        animatingImageView.stopAnimating()
    }
    
}
