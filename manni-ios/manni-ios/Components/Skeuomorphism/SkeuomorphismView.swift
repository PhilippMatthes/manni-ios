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
    
    public var lightColor: UIColor = Color.grey.lighten4 {
        didSet {
            lightShadowLayer.shadowColor = lightColor.cgColor
            contentView.backgroundColor = lightColor
        }
    }
    
    public var cornerRadius: CGFloat = 32 {
        didSet {
            lightShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            darkShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            contentView.layer.cornerRadius = cornerRadius
        }
    }
    
    public let contentView = View()
    
    override func prepare() {
        super.prepare()
        layer.cornerRadius = cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lightShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        lightShadowLayer.fillColor = UIColor.clear.cgColor
        lightShadowLayer.shadowColor = lightColor.cgColor
        lightShadowLayer.shadowPath = lightShadowLayer.path
        lightShadowLayer.shadowOffset = CGSize(width: -3.0, height: -3.0)
        lightShadowLayer.shadowOpacity = 0.6
        lightShadowLayer.shadowRadius = 4
        layer.insertSublayer(lightShadowLayer, at: 0)
        
        darkShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        darkShadowLayer.fillColor = UIColor.clear.cgColor
        darkShadowLayer.shadowColor = UIColor("#000033").cgColor
        darkShadowLayer.shadowPath = darkShadowLayer.path
        darkShadowLayer.shadowOffset = CGSize(width: 3.0, height: 5.0)
        darkShadowLayer.shadowOpacity = 0.2
        darkShadowLayer.shadowRadius = 12
        layer.insertSublayer(darkShadowLayer, at: 0)
        
        layout(contentView).edges()
        contentView.layer.cornerRadius = cornerRadius
    }
    
}
