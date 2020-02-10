//
//  VerticalProgressBar.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 10.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material


class VerticalProgressBarView: View {
    private var progressBackgroundView = UIView()
    private var progressView = UIView()
    
    public var progressBarColor: UIColor = .black {
        didSet {
            progressView.backgroundColor = progressBarColor
        }
    }
    
    public var progressBackgroundColor: UIColor = .white {
        didSet {
            progressBackgroundView.backgroundColor = progressBackgroundColor
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            let threshold: CGFloat = 100.0
            let yOffset = ((threshold - progress) / threshold) * frame.size.height
            
            if progress <= 0 || progress >= 100 {
                self.layoutIfNeeded()
                self.progressView.frame.size.height = self.frame.size.height - yOffset
                self.progressView.frame.origin.y = yOffset
            } else {
                UIView.animate(withDuration: 1.0, animations: {
                    self.layoutIfNeeded()
                    self.progressView.frame.size.height = self.frame.size.height - yOffset
                    self.progressView.frame.origin.y = yOffset
                })
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .clear

        progressBackgroundView.frame = .init(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        progressBackgroundView.backgroundColor = progressBackgroundColor
        addSubview(progressBackgroundView)

        progressView.frame = .init(x: 0.0, y: frame.size.height, width: frame.size.width, height: 0.0)
        progressView.backgroundColor = progressBarColor
        addSubview(progressView)
        
        let threshold: CGFloat = 100.0
        let yOffset = ((threshold - progress) / threshold) * frame.size.height
        self.progressView.frame.size.height = self.frame.size.height - yOffset
        self.progressView.frame.origin.y = yOffset
    }
    
}
