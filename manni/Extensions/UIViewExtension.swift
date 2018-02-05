//
//  UIViewExtension.swift
//  manni
//
//  Created by Philipp Matthes on 01.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func blur(style: UIBlurEffectStyle = .extraLight, color: UIColor = .white, alpha: CGFloat = 0.5) {
        self.backgroundColor = color.withAlphaComponent(alpha)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let mainBlurEffectView = UIVisualEffectView(effect: blurEffect)
        mainBlurEffectView.layer.zPosition = -1000
        mainBlurEffectView.frame = self.bounds
        mainBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mainBlurEffectView)
    }
    
    func isBlurred() -> Bool {
        for subview in self.subviews {
            if let subview = subview as? UIVisualEffectView {
                if let _ = subview.effect as? UIBlurEffect {
                    return true
                }
            }
        }
        return false
    }
}
