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
            lightColor = Color.grey.lighten5
            contentView.backgroundColor = .white
            stopLabel.text = stop.name
            stopLabel.textColor = .black
        }
    }
    
    public var isSelected: Bool? {
        didSet {
            if isSelected == true {
                self.borderLayer.lineDashPattern = nil
                self.borderLayer.lineWidth = 3
                self.borderLayer.strokeColor = Color.blue.accent4.cgColor
            } else {
                self.borderLayer.lineDashPattern = [4, 4]
                self.borderLayer.lineWidth = 1
                self.borderLayer.strokeColor = Color.grey.base.cgColor
            }
        }
    }
    
    public let stopLabel = UILabel()
    public let borderLayer = CAShapeLayer()
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 11.0, *) {
            prepareDropInteraction()
            prepareDragInteraction()
        }
        
        lightShadowOpacity = 0
        darkShadowOpacity = 0
        
        stopLabel.font = RobotoFont.regular(with: 22)
        
        isSelected = false
        borderLayer.fillColor = nil
        borderLayer.lineCap = .round
        borderLayer.lineJoin = .round
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(stopLabel)
            .centerY()
            .left(16)
            .right(16)

        borderLayer.frame = bounds
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
    
    @objc func didTapView() {
        if let isSelected = isSelected {
            self.isSelected = !isSelected
        } else {
            self.isSelected = true
        }
    }
    
}


extension RouteStopInputView: Revealable {
    func prepareReveal() {
        stopLabel.alpha = 0
    }
    
    func reveal(reverse: Bool, completion: @escaping (() -> ())) {
        if reverse {
            UIView.animate(withDuration: 0.2, animations: {
                self.stopLabel.alpha = 0
            }, completion: {
                _ in
                completion()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.stopLabel.alpha = 1
            }, completion: {
                _ in
                completion()
            })
        }
    }
}

@available(iOS 11.0, *)
extension RouteStopInputView: UIDragInteractionDelegate {
    func prepareDragInteraction() {
        isUserInteractionEnabled = true
        addInteraction(UIDragInteraction(delegate: self))
    }
        
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let stop = stop else {return []}
        let itemProvider = NSItemProvider(object: StopItem(stop: stop))
        return [UIDragItem(itemProvider: itemProvider)]
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
        isSelected = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        isSelected = false
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        isSelected = false
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
