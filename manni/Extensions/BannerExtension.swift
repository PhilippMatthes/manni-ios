//
//  BannerExtension.swift
//  manni
//
//  Created by Philipp Matthes on 30.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import BRYXBanner
import Material
import Motion

extension Banner {
    func designed() -> Banner {
        self.position = .bottom
        self.dismissesOnTap = true
        self.dismissesOnSwipe = true
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.black
        return self
    }
    
    func dismissAssign() -> Banner {
        self.dismiss()
        return self
    }
    
    func showAssign() -> Banner {
        self.show()
        return self
    }
    
    func showAssign(duration: Double) -> Banner {
        self.show(duration: duration)
        return self
    }
    
    convenience init(title: String) {
        self.init(title: title, subtitle: nil, image: Icon.cm.search, backgroundColor: UIColor.white, didTapBlock: nil)
    }
}
