//
//  ViewController.swift
//  manni
//
//  Created by Philipp Matthes on 25.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//


import UIKit
import Material

class ModularSearchBarController: SearchBarController {
    fileprivate var searchButton: IconButton!
    fileprivate var dismissButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareSearchButton()
        prepareDismissButton()
        prepareStatusBar()
        prepareSearchBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.textField.becomeFirstResponder()
    }
}

extension ModularSearchBarController {
    func prepareDismissButton() {
        dismissButton = IconButton(image: Icon.cm.arrowDownward)
        dismissButton.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
    }
    
    func prepareSearchButton() {
        searchButton = IconButton(image: Icon.cm.search)
        searchButton.addTarget(self, action: #selector(search(sender:)), for: .touchUpInside)
    }
    
    func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    func prepareSearchBar() {
        searchBar.leftViews = [dismissButton]
        searchBar.rightViews = [searchButton]
        searchBar.placeholder = "Haltestelle suchen"
    }
    
    @objc func dismiss(sender: UIButton!) {
        dismissKeyboard()
    }
    
    @objc func search(sender: UIButton!) {
        print("Search")
    }
}




