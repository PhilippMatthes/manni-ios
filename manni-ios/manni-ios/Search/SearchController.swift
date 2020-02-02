//
//  SearchController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import Material
import DVB


class SearchController: ViewController {
    fileprivate let searchViewBackground = UIVisualEffectView()
    fileprivate let searchView = SearchView()
    fileprivate let tableView = TableView()
    
    fileprivate var stops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareBackgroundView()
        prepareTableView()
        prepareSearchViewBackground()
        prepareSearchView()
        
        Stop.find("Tharandter Straße") {
            result in
            guard let success = result.success else {return}
            self.stops = success.stops
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchController {
    fileprivate func prepareBackgroundView() {
        view.backgroundColor = Color.blue.base
    }
    
    fileprivate func prepareTableView() {
        view.layout(tableView).edges()
        tableView.register(
            StopTableViewCell.self,
            forCellReuseIdentifier: StopTableViewCell.reuseIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: 128, right: 0)
        tableView.backgroundColor = .clear
    }
    
    fileprivate func prepareSearchViewBackground() {
        view.layout(searchViewBackground)
            .bottom()
            .left()
            .right()
        searchViewBackground.effect = UIBlurEffect(style: .light)
        searchViewBackground.clipsToBounds = true
        searchViewBackground.layer.cornerRadius = 32.0
    }
    
    fileprivate func prepareSearchView() {
        searchViewBackground.contentView.layout(searchView)
            .edgesSafe(top: 12, left: 12, bottom: 12, right: 12)
    }
}

extension SearchController {
    @objc func keyboardWillShow(notification:NSNotification){
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        else {return}
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        view.frame.origin.y = -keyboardFrame.size.height
    }

    @objc func keyboardWillHide(notification:NSNotification){
        view.frame.origin.y = 0
    }
}

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StopTableViewCell.reuseIdentifier, for: indexPath
        ) as! StopTableViewCell
        cell.stop = stops[indexPath.row]
        return cell
    }
}
