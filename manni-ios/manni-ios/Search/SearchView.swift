//
//  SearchView.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 02.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import Motion
import DVB
import FontAwesome_swift


protocol SearchViewDelegate {
    func search(query: String)
    func search(routeFrom departureStop: Stop, to destinationStop: Stop)
}


class SearchView: View {
    
    private let searchViewBackground = UIView()
    private let routeStopView = UIView()
    private let routeStopDepartureInputView = RouteStopInputView()
    private let routeStopDestinationInputView = RouteStopInputView()
    private let routeStopDividerView = UIView()
    private let searchRouteButton = SkeuomorphismIconButton(
       image: UIImage.fontAwesomeIcon(name: .route, style: .solid, textColor: .white, size: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate),
       tintColor: Color.grey.base
   )
    private let queryFieldView = SkeuomorphismView()
    private let queryField = UITextField()
    private let searchButton = IconButton(image: UIImage.fontAwesomeIcon(name: .search, style: .solid, textColor: .white, size: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), tintColor: Color.grey.base)
    private let searchButtonAnimatingImageView = UIImageView()
    
    public var delegate: SearchViewDelegate?
    
    private var suggestions: [String]?
    private var computingQuery: String?
    private var routeStops = [Stop]()
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        prepareRouteView()
        prepareRouteStopInputViews()
        prepareSearchRouteButton()
        prepareSuggestions()
        prepareQueryFieldView()
        prepareQueryField()
        prepareSearchButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout(searchViewBackground).edges()
        searchViewBackground.backgroundColor = .white
        searchViewBackground.clipsToBounds = true
        searchViewBackground.layer.cornerRadius = 16
        
        searchViewBackground.layout(routeStopView)
            .top(16)
            .left(16)
            .right(16)
            .height(48)
        
        routeStopView.layout(searchRouteButton)
            .left()
            .height(48)
            .width(48)
            .top()
        
        // Center anchor point
        routeStopView.layout(routeStopDividerView)
            .top()
            .centerX(24)
            .width(0)
            .bottom()
        
        routeStopView.layout(routeStopDepartureInputView)
            .top()
            .after(searchRouteButton, 8)
            .before(routeStopDividerView, 4)
            .bottom()
        
        routeStopView.layout(routeStopDestinationInputView)
            .top()
            .right()
            .after(routeStopDividerView, 4)
            .bottom()
        
        searchViewBackground.layout(queryFieldView)
            .below(routeStopView, 16)
            .left(16)
            .right(16)
            .bottom(16)
        
        queryFieldView.contentView.layout(searchButton)
            .left()
            .top()
            .bottom()
            .width(48)
            .height(48)
        
        queryFieldView.contentView.layout(queryField)
            .top(8)
            .bottom(8)
            .after(searchButton)
            .right(12)
            .centerY()
    }
    
    @objc func selectQueryField() {
        queryField.becomeFirstResponder()
    }
    
    @objc func searchRoute() {
        guard
            let departureStop = routeStopDepartureInputView.stop,
            let destinationStop = routeStopDestinationInputView.stop
        else {return}
        delegate?.search(routeFrom: departureStop, to: destinationStop)
    }
    
}

extension SearchView: Revealable {
    func prepareReveal() {
        transform = CGAffineTransform
            .init(translationX: 0, y: 178)
        searchButton.alpha = 0
        searchRouteButton.alpha = 0
        routeStopDepartureInputView.prepareReveal()
        routeStopDestinationInputView.prepareReveal()
    }
    
    func reveal(completion: @escaping (() -> ())) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.searchRouteButton.alpha = 1
            self.searchButton.alpha = 1
            self.transform = CGAffineTransform
                .init(translationX: 0, y: 0)
        }, completion: {
            _ in
            self.routeStopDepartureInputView.reveal {
                self.routeStopDestinationInputView.reveal {
                    completion()
                }
            }
        })
    }
}

extension SearchView {
    fileprivate func prepareRouteView() {
        routeStopView.layer.cornerRadius = 24
        routeStopView.backgroundColor = Color.grey.lighten4
    }
    
    fileprivate func prepareRouteStopInputViews() {
        routeStopDepartureInputView.stopLabel.text = "Von"
        routeStopDepartureInputView.stopLabel.textColor = Color.grey.base
        routeStopDepartureInputView.contentView.backgroundColor = Color.grey.lighten4
        routeStopDestinationInputView.stopLabel.text = "Nach"
        routeStopDestinationInputView.stopLabel.textColor = Color.grey.base
        routeStopDestinationInputView.contentView.backgroundColor = Color.grey.lighten4
    }
    
    fileprivate func prepareSearchRouteButton() {
        searchRouteButton.skeuomorphismView.cornerRadius = 32
        searchRouteButton.skeuomorphismView.lightShadowOpacity = 0.3
        searchRouteButton.skeuomorphismView.contentView.backgroundColor = Color.grey.lighten4
        searchRouteButton.pulseColor = Color.blue.base
        searchRouteButton.addTarget(self, action: #selector(searchRoute), for: .touchUpInside)
    }
    
    fileprivate func prepareSuggestions() {
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
    
    fileprivate func prepareQueryFieldView() {
        queryFieldView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectQueryField)))
        queryFieldView.contentView.backgroundColor = Color.grey.lighten4
        queryFieldView.cornerRadius = 16
        queryFieldView.lightShadowOpacity = 0
        queryFieldView.darkShadowOpacity = 0
    }
    
    fileprivate func prepareSearchButton() {
        searchButton.pulseColor = Color.blue.base
        searchButton.addTarget(self, action: #selector(searchStop), for: .touchUpInside)
    }
    
    fileprivate func prepareQueryField() {
        queryField.delegate = self
        queryField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectQueryField)))
        queryField.font = RobotoFont.regular(with: 22)
        queryField.placeholder = "Haltestelle suchen"
        queryField.clearButtonMode = .always
    }
}

extension SearchView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: StopTableViewCell.reuseIdentifier, for: indexPath
        ) as! StopTableViewCell
        let stop = routeStops[indexPath.row]
        if cell.stop != stop {
            cell.stop = stop
        }
        cell.isSuggestion = false
        return cell
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
