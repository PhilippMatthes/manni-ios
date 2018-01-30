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
    fileprivate var dismissButton: IconButton!
    fileprivate var listButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareDismissButton()
        prepareListButton()
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
    
    func prepareListButton() {
        listButton = IconButton(image: Icon.cm.menu)
        listButton.addTarget(self, action: #selector(list(sender:)), for: .touchUpInside)
    }
    
    func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    func prepareSearchBar() {
        searchBar.leftViews = [dismissButton]
        searchBar.rightViews = [listButton]
        searchBar.placeholder = Config.searchBarPlaceHolder
    }
    
    @objc func dismiss(sender: UIButton!) {
        dismissKeyboard()
    }
    
    @objc func list(sender: UIButton!) {
//        if let rvc = rootViewController as? RootSearchBarController {
//
//        }
    }
}




