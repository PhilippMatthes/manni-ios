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


class SearchView: SkeuomorphismView {
    
    private let textField = UITextField()
    private let placeholderTextField = UITextField()
    private let searchButton = SkeuomorphismIconButton(image: Icon.search, tintColor: Color.grey.darken4)
    
    public var delegate: SearchViewDelegate?
    
    private var suggestions: [String]?
    private var computingQuery: String?
    
    override func prepare() {
        super.prepare()
        
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(searchButton)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        searchButton.pulseColor = Color.blue.base
        searchButton.addTarget(self, action: #selector(searchStop), for: .touchUpInside)
        
        contentView.layout(textField)
            .left(24)
            .top(8)
            .bottom(8)
            .before(searchButton, 12)
            .height(48)
        textField.delegate = self
        textField.font = RobotoFont.light(with: 24)
        textField.placeholder = "Haltestelle"
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
        textField.resignFirstResponder()
        if let query = textField.text, query != "" {
            delegate?.search(query: query)
        }
        return
    }
}
