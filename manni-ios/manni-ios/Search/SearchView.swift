//
//  SearchView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import Motion


protocol SearchViewDelegate {
    func search(query: String)
}


class SearchView: View {
    
    private let queryFieldView = SkeuomorphismView()
    private let queryField = UITextField()
    private let searchButton = SkeuomorphismIconButton(image: Icon.search, tintColor: Color.grey.darken4)
    private let searchButtonAnimatingImageView = UIImageView()
    
    public var delegate: SearchViewDelegate?
    
    private var suggestions: [String]?
    private var computingQuery: String?
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        searchButtonAnimatingImageView.animationImages = (0...89).map {
            UIImage(named: "animation000\($0).png")!
        }
        searchButtonAnimatingImageView.animationDuration = 3
        
        DispatchQueue.global(qos: .background).async {
            guard
                let path = Bundle.main.path(forResource: "stations", ofType: "json"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
                let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
                let features = jsonResult["features"] as? [Any]
            else {
                print("The stations file could not be read.")
                return
            }
            self.suggestions = []
            for feature in features {
                guard
                    let featureDict = feature as? [String: Any],
                    let propertiesDict = featureDict["properties"] as? [String: Any]
                else {continue}
                if let city = propertiesDict["city"] as? String, city == "Dresden" {
                    guard let name = propertiesDict["name"] as? String else {continue}
                    self.suggestions?.append(name)
                } else {
                    guard let name = propertiesDict["nameWithCity"] as? String else {continue}
                    self.suggestions?.append(name)
                }
            }
        }
    }
    
    public func startRefreshing() {
        searchButton.animate(MotionAnimation.fadeOut)
        searchButtonAnimatingImageView.animate([
            MotionAnimation.scale(1.5)
        ])
        self.searchButtonAnimatingImageView.startAnimating()
    }
    
    public func endRefreshing() {
        searchButton.animate(MotionAnimation.fadeIn)
        searchButtonAnimatingImageView.animate([
            MotionAnimation.scale(1.0)
        ])
        self.searchButtonAnimatingImageView.stopAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout(queryFieldView)
            .top()
            .left()
            .right()
            .bottom()
        queryFieldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectQueryField)))
        
        queryFieldView.contentView.layout(searchButton)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        searchButton.pulseColor = Color.blue.base
        searchButton.addTarget(self, action: #selector(searchStop), for: .touchUpInside)
        
        queryFieldView.contentView.layout(searchButtonAnimatingImageView)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        
        queryFieldView.contentView.layout(queryField)
            .left(24)
            .top(8)
            .bottom(8)
            .before(searchButton, 12)
            .height(48)
        queryField.delegate = self
        queryField.font = RobotoFont.light(with: 24)
        queryField.placeholder = "Haltestelle"
        queryField.clearButtonMode = .always
        queryField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectQueryField)))
    }
    
    @objc func selectQueryField() {
        queryField.becomeFirstResponder()
    }
    
}

extension SearchView: UITextFieldDelegate {    
    func autoCompleteText( in textField: UITextField, using string: String, suggestions: [String]) -> Bool {
        if
            !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange,
            selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(
                from: textField.beginningOfDocument,
                to: selectedTextRange.start
            ),
            let text = textField.text( in : prefixRange)
        {
            let prefix = text + string
            let matches = suggestions.filter {
                $0.hasPrefix(prefix)
            }
            if (matches.count > 0) {
                textField.text = matches[0]
                if let start = textField.position(
                    from: textField.beginningOfDocument,
                    offset: prefix.count
                ) {
                    textField.selectedTextRange = textField.textRange(
                        from: start, to: textField.endOfDocument
                    )
                    return true
                }
            }
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let suggestions = suggestions else {return true}
        return !autoCompleteText(in : textField, using: string, suggestions: suggestions)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let query = textField.text, query != "" {
            delegate?.search(query: query)
        }
        return true
    }
    
    @objc func searchStop() {
        queryField.resignFirstResponder()
        if let query = queryField.text, query != "" {
            delegate?.search(query: query)
        }
        return
    }
}
