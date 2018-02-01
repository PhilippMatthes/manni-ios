//
//  RaisedButtonExtension.swift
//  manni
//
//  Created by Philipp Matthes on 31.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import SwiftSVG

extension UIButton {
    func downloadAndSetImage(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        let imageView = UIView(SVGURL: url) { (svgLayer) in
            svgLayer.fillColor = UIColor(red:0.52, green:0.16, blue:0.32, alpha:1.00).cgColor
            svgLayer.resizeToFit(self.bounds)
        }
        self.layer.addSublayer(imageView.layer)
    }
}
