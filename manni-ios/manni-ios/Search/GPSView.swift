//
//  GPSView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 04.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import FontAwesome_swift


class GPSView: SkeuomorphismView {
    
    fileprivate let startImageView = UIImageView()
    fileprivate let animatingImageView = UIImageView()
    fileprivate let pullIcon = UIImageView(image: UIImage.fontAwesomeIcon(name: .chevronDown, style: .solid, textColor: .white, size: .init(width: 32, height: 32)))
    
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
        
        contentView.backgroundColor = Color.blue.accent4
        
        for imageView in [startImageView, animatingImageView] {
            contentView.layout(imageView)
                .bottom(56)
                .centerX()
                .height(128)
                .width(128)
        }
        
        contentView.layout(pullIcon)
            .bottom(36)
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

extension GPSView: Revealable {
    func prepareReveal() {
        pullIcon.transform = .init(translationX: 0, y: -64)
    }
    
    func reveal(reverse: Bool, completion: @escaping (() -> ())) {
        if reverse {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.pullIcon.transform = .init(translationX: 0, y: -64)
            }, completion: {
                _ in
                completion()
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.pullIcon.transform = .identity
            }, completion: {
                _ in
                completion()
            })
        }
    }
}
