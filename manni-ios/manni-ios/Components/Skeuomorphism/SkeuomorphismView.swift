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
            lightShadowLayer.shadowColor = lightColor.interpolate(
                to: Color.grey.lighten4, 0.7
            )?.cgColor
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
    
    public var lightShadowOpacity: Float = 1 {
        didSet {
            lightShadowLayer.shadowOpacity = lightShadowOpacity
        }
    }
    
    public var darkShadowOpacity: Float = 0.05 {
        didSet {
            darkShadowLayer.shadowOpacity = darkShadowOpacity
        }
    }
    
    public let contentView = View()
    
    override func prepare() {
        super.prepare()
        layer.cornerRadius = cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        darkShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        darkShadowLayer.shadowPath = darkShadowLayer.path
        if layer.sublayers?.contains(darkShadowLayer) == false {
            darkShadowLayer.fillColor = UIColor.clear.cgColor
            darkShadowLayer.shadowColor = UIColor("#000033").cgColor
            darkShadowLayer.shadowOffset = CGSize(width: 3.0, height: 5.0)
            darkShadowLayer.shadowOpacity = darkShadowOpacity
            darkShadowLayer.shadowRadius = 4
            layer.insertSublayer(darkShadowLayer, at: 0)
        }
        
        lightShadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        lightShadowLayer.shadowPath = lightShadowLayer.path
        if layer.sublayers?.contains(lightShadowLayer) == false {
            lightShadowLayer.fillColor = UIColor.clear.cgColor
            lightShadowLayer.shadowColor = lightColor.interpolate(
                to: Color.grey.lighten4, 0.7
            )?.cgColor
            lightShadowLayer.shadowOffset = CGSize(width: -3.0, height: -3.0)
            lightShadowLayer.shadowOpacity = lightShadowOpacity
            lightShadowLayer.shadowRadius = 4
            layer.insertSublayer(lightShadowLayer, at: 0)
        }
        
        
        if !subviews.contains(contentView) {
            layout(contentView).edges()
        }
        contentView.layer.cornerRadius = cornerRadius
    }
    
}
