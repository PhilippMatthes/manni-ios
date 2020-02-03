//
//  SearchView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material


class SearchView: SkeuomorphismView {
    
    public let textField = UITextField()
    public let searchButton = SkeuomorphismIconButton(image: Icon.search, tintColor: Color.grey.darken4)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(searchButton)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        searchButton.pulseColor = Color.blue.base
            
        contentView.layout(textField)
            .left(24)
            .top(8)
            .bottom(8)
            .before(searchButton, 12)
            .height(48)
        textField.font = RobotoFont.light(with: 24)
    }
    
}
