//
//  NavigationItemExtension.swift
//  manni
//
//  Created by Philipp Matthes on 07.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import Motion

enum ButtonType {
    case returnButton
    case positionButton
    case refreshButton
}

enum ButtonLocation {
    case left
    case right
}

extension UINavigationItem {
    func configure(withText text: String) {
        self.titleLabel.text = text
        self.titleLabel.textColor = UIColor.black
        self.hidesBackButton = false
    }
    
    func add(_ type: ButtonType, _ location: ButtonLocation, completion: @escaping () -> ()) -> UIButton {
        let button = UIButton(type: .custom)
        switch type {
        case .positionButton:
            button.setImage(Icon.home, for: .normal)
        case .returnButton:
            button.setImage(Icon.cm.arrowBack, for: .normal)
        case .refreshButton:
            button.setImage(Icon.search, for: .normal)
        }
        button.tintColor = UIColor.black
        button.setTitleColor(UIColor.black, for: .normal)
        button.add(for: .touchUpInside) { completion() }
        let buttonItem = UIBarButtonItem(customView: button)
        switch location {
        case .left:
            if let leftItems = leftBarButtonItems {setLeftBarButtonItems(leftItems + [buttonItem], animated: true)}
            else {setLeftBarButtonItems([buttonItem], animated: true)}
        case .right:
            if let rightItems = rightBarButtonItems {setRightBarButtonItems(rightItems + [buttonItem], animated: true)}
            else {setRightBarButtonItems([buttonItem], animated: true)}
        }
        return button
    }
}
