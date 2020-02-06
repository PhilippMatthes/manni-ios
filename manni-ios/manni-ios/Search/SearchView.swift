//
//  SearchView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material


protocol SearchViewDelegate {
    func search(query: String)
}


class SearchView: View {
    
    private let suggestionBadge = SkeuomorphismView()
    private let suggestionBadgeLabel = UILabel()
    
    private let suggestionView = SkeuomorphismView()
    private let suggestionLabel = UILabel()
    
    private let queryFieldView = SkeuomorphismView()
    private let queryField = UITextField()
    private let searchButton = SkeuomorphismIconButton(image: Icon.search, tintColor: Color.grey.darken4)
    
    public var delegate: SearchViewDelegate?
    
    private var suggestions: [String]?
    private var computingQuery: String?
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        DispatchQueue.global(qos: .background).async {
            guard
                let path = Bundle.main.path(forResource: "stations", ofType: "json"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
                let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any],
                let features = jsonResult["features"] as? [Any]
            else {return}
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
        
        reloadSuggestion()
    }
    
    func reloadSuggestion() {
        let currentSuggestionLabelText = self.suggestionLabel.text
        Search.predictQuery() {
            query in
            DispatchQueue.main.async {
                guard let query = query, query != "" else {
                    self.suggestionLabel.text = "Dresden, Hauptbahnhof"
                    return
                }
                // If the text has changed, cancel the action
                guard self.suggestionLabel.text == currentSuggestionLabelText else {return}
                self.suggestionLabel.text = query
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout(suggestionView)
            .top(12)
            .left()
            .right()
        
        suggestionView.contentView.layout(suggestionLabel)
            .edges(top: 16, left: 24, bottom: 16, right: 24)
        suggestionLabel.font = RobotoFont.light(with: 24)
        suggestionLabel.textColor = Color.grey.darken3
        suggestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectSuggestion)))
        
        layout(suggestionBadge)
            .top()
            .right(18)
        suggestionBadge.lightColor = UIColor("#0652DD")
        suggestionBadge.cornerRadius = 12
        
        suggestionBadge.contentView.layout(suggestionBadgeLabel)
            .edges(top: 4, left: 8, bottom: 4, right: 8)
        suggestionBadgeLabel.font = RobotoFont.light(with: 12)
        suggestionBadgeLabel.textColor = .white
        suggestionBadgeLabel.text = "Vorschlag"
        
        layout(queryFieldView)
            .below(suggestionView, 12)
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
        
        queryFieldView.contentView.layout(queryField)
            .left(24)
            .top(8)
            .bottom(8)
            .before(searchButton, 12)
            .height(48)
        queryField.delegate = self
        queryField.font = RobotoFont.light(with: 24)
        queryField.placeholder = "Haltestelle"
    }
    
    @objc func selectQueryField() {
        queryField.becomeFirstResponder()
    }
    
    @objc func didSelectSuggestion() {
        queryField.text = suggestionLabel.text
        queryField.resignFirstResponder()
        if let query = queryField.text, query != "" {
            delegate?.search(query: query)
        }
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
