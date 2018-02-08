//  MIT License
//
//  Copyright (c) 2018 Philipp Matthes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Philipp Matthes on 02.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UITabBar {
    func setTintColor(ofUnselectedItemsWithColor unselectedColor: UIColor, andSelectedItemsWithColor selectedColor: UIColor) {
        if let items = items {
            for item in items {
                item.selectedImage = item.image?.alpha(1.0).withRenderingMode(.alwaysOriginal)
                item.image =  item.selectedImage?.alpha(0.5).withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : unselectedColor], for: .normal)
                item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : selectedColor], for: .selected)
            }
        }
    }
    
    func animate(toSelectedItemTintColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.tintColor = color
        }) { (success) -> Void in
            self.tintColor = color
        }
    }
    
    func animate(toBarTintColor color: UIColor, withDuration duration: CFTimeInterval){
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: { () -> Void in
            self.barTintColor = color
            self.barStyle = .black
        }, completion: nil)
    }
}
