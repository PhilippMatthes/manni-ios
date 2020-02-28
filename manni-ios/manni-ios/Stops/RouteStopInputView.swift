//
//  RouteStopInputView.swift
//  manni-ios
//
//  Created by It's free real estate on 26.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import DVB
import Motion


class RouteStopInputView: SkeuomorphismView {
    
    public var stop: Stop? {
        didSet {
            guard let stop = stop else {return}
            lightColor = stop.gradient.first ?? .white
            gradient = stop.gradient
            stopLabel.text = stop.name
            stopLabel.textColor = .white
            layoutSubviews()
        }
    }
    
    public let stopLabel = UILabel()
    public let borderLayer = CAShapeLayer()
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 11.0, *) {
            prepareDropInteraction()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(stopLabel)
            .centerY()
            .left(16)
            .right(16)
        stopLabel.font = RobotoFont.regular(with: 22)
        
        lightShadowOpacity = 0
        darkShadowOpacity = 0
        
        borderLayer.strokeColor = Color.grey.base.cgColor
        borderLayer.lineDashPattern = [4, 4]
        borderLayer.lineCap = .round
        borderLayer.lineJoin = .round
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.cornerRadius = cornerRadius
        let roundedCorners: UIRectCorner = self.roundedCorners ?? UIRectCorner.allCorners
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: roundedCorners,
            cornerRadii: .init(width: cornerRadius, height: cornerRadius)
        ).cgPath
        borderLayer.path = path
        layer.addSublayer(borderLayer)
    }
    
}


extension RouteStopInputView: Revealable {
    func prepareReveal() {
        borderLayer.strokeEnd = 0
        
        stopLabel.alpha = 0
    }
    
    func reveal(completion: @escaping (() -> ())) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0)
        animation.toValue = CGFloat(1)
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        borderLayer.add(animation, forKey: "strokeAnimation")
        
        UIView.animate(withDuration: 1, animations: {
            self.stopLabel.alpha = 1
        }, completion: {
            _ in
            completion()
        })
    }
}


@available(iOS 11.0, *)
extension RouteStopInputView: UIDropInteractionDelegate {
    fileprivate func prepareDropInteraction() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: StopItem.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: StopItem.self) {
            stopItems in
            guard let stopItem = stopItems.first as? StopItem else {return}
            self.stop = stopItem.stop
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
