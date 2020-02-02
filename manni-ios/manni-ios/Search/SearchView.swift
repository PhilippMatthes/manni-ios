//
//  SearchView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material


class SearchView: SkeuomorphismView {
    
    public let textField = TextField()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        prepareTextField()
    }
    
    fileprivate func prepareTextField() {
        contentView.layout(textField)
            .edges(top: 12, left: 24, bottom: 12, right: 24)
        textField.isPlaceholderAnimated = false
    }
    
}
