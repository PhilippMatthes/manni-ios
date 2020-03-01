//
//  LoadingView.swift
//  manni-ios
//
//  Created by It's free real estate on 01.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import UIKit
import Material


class LoadingView: View {
    
    public var gradientsDuringLoading: [[CGColor]] = [
        [Color.grey.lighten5.cgColor, Color.grey.lighten3.cgColor, Color.grey.lighten3.cgColor],
        [Color.grey.lighten3.cgColor, Color.grey.lighten5.cgColor, Color.grey.lighten3.cgColor],
        [Color.grey.lighten3.cgColor, Color.grey.lighten3.cgColor, Color.grey.lighten5.cgColor],
    ] {
        didSet {
            guard gradientsDuringLoading.count > 0 else {
                fatalError("A LoadingView must be supplied with at least one color.")
            }
            loadingGradientLayer.colors = gradientsDuringLoading
        }
    }
    
    public var isLoading: Bool = false {
        didSet {
            let value = isLoading
            DispatchQueue.main.async {
                guard value == self.isLoading else {return}
                if value {
                    self.animateGradient()
                    self.loadingGradientLayer.isHidden = false
                    
                    for view in self.fakedViews {
                        view.backgroundColor = Color.grey.lighten2
                    }
                } else {
                    self.loadingGradientLayer.removeAllAnimations()
                    self.loadingGradientLayer.isHidden = true
                    
                    for view in self.fakedViews {
                        view.backgroundColor = .clear
                    }
                }
            }
        }
    }
    
    public var fakedViews = [UIView]()
    
    fileprivate let loadingGradientLayer = CAGradientLayer()
    fileprivate var gradientAnimation: CABasicAnimation?
    fileprivate var currentGradient = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingGradientLayer.frame = bounds
        loadingGradientLayer.startPoint = .init(x: 0, y: 0)
        loadingGradientLayer.endPoint = .init(x: 1, y: 1)
        loadingGradientLayer.drawsAsynchronously = true
        layer.insertSublayer(loadingGradientLayer, at: 0)
    }
}

extension LoadingView: CAAnimationDelegate {
    fileprivate func animateGradient() {
        loadingGradientLayer.colors = gradientsDuringLoading[currentGradient]
        currentGradient = (currentGradient + 1) % gradientsDuringLoading.count
        gradientAnimation = CABasicAnimation(keyPath: "colors")
        gradientAnimation!.duration = 0.5
        gradientAnimation!.toValue = gradientsDuringLoading[currentGradient]
        gradientAnimation!.fillMode = .forwards
        gradientAnimation!.timingFunction = .linear
        gradientAnimation!.isRemovedOnCompletion = false
        gradientAnimation!.delegate = self
        loadingGradientLayer.add(gradientAnimation!, forKey: "colorChange")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && isLoading {
            animateGradient()
        }
    }
}
