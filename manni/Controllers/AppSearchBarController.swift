//
//  SearchBarController.swift
//  manni
//
//  Created by Philipp Matthes on 26.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

import UIKit
import Material

class AppSearchBarController: SearchBarController {
    private var menuButton: IconButton!
    private var moreButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareMenuButton()
        prepareMoreButton()
        prepareStatusBar()
        prepareSearchBar()
    }
    
    private func prepareMenuButton() {
        menuButton = IconButton(image: Icon.cm.menu)
    }
    
    private func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical)
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        
        // Access the statusBar.
        //        statusBar.backgroundColor = Color.grey.base
    }
    
    private func prepareSearchBar() {
        searchBar.leftViews = [menuButton]
        searchBar.rightViews = [moreButton]
    }
}
