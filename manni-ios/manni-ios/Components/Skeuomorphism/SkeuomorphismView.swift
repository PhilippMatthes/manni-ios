//
//  SkeuomorphismView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material


class SkeuomorphismView: View {
    
    fileprivate let lightShadowLayer = CAShapeLayer()
    fileprivate let darkShadowLayer = CAShapeLayer()
    public let contentView = View()
    
    override func prepare() {
        super.prepare()
        layer.cornerRadius = 32
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lightShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 32).cgPath
        lightShadowLayer.fillColor = UIColor.clear.cgColor
        lightShadowLayer.shadowColor = UIColor.white.cgColor
        lightShadowLayer.shadowPath = lightShadowLayer.path
        lightShadowLayer.shadowOffset = CGSize(width: -3.0, height: -3.0)
        lightShadowLayer.shadowOpacity = 0.5
        lightShadowLayer.shadowRadius = 4
        layer.insertSublayer(lightShadowLayer, at: 0)
        
        darkShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 32).cgPath
        darkShadowLayer.fillColor = UIColor.clear.cgColor
        darkShadowLayer.shadowColor = UIColor.black.cgColor
        darkShadowLayer.shadowPath = darkShadowLayer.path
        darkShadowLayer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        darkShadowLayer.shadowOpacity = 0.2
        darkShadowLayer.shadowRadius = 4
        layer.insertSublayer(darkShadowLayer, at: 0)
        
        layout(contentView).edges()
        contentView.layer.cornerRadius = 24
    }
    
}
