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
        stopLabel.font = RobotoFont.light(with: 24)
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
