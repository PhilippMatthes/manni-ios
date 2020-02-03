//
//  SkeuomorphismIconButton.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 03.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material

class SkeuomorphismIconButton: IconButton {
    
    let skeuomorphismView = SkeuomorphismView()
    
    override func prepare() {
        super.prepare()
        layout(skeuomorphismView).edges()
        skeuomorphismView.layer.zPosition = -1
    }
    
}
