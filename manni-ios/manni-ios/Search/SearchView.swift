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
    
    private let routeStopView = SkeuomorphismView()
    private let routeStopDepartureInputView = RouteStopInputView()
    private let routeStopDestinationInputView = RouteStopInputView()
    private let routeStopDividerView = UIView()
    private let searchRouteButton = SkeuomorphismIconButton(
       image: UIImage.fontAwesomeIcon(name: .route, style: .solid, textColor: .white, size: .init(width: 32, height: 32)).withRenderingMode(.alwaysTemplate),
       tintColor: Color.grey.darken4
   )
    private let queryFieldView = SkeuomorphismView()
    private let queryField = UITextField()
    private let searchButton = SkeuomorphismIconButton(image: UIImage.fontAwesomeIcon(name: .searchLocation, style: .solid, textColor: .white, size: .init(width: 32, height: 32)).withRenderingMode(.alwaysTemplate), tintColor: Color.grey.darken4)
    private let searchButtonAnimatingImageView = UIImageView()
    
    public var delegate: SearchViewDelegate?
    
    private var suggestions: [String]?
    private var computingQuery: String?
    private var routeStops = [Stop]()
    
    override func prepare() {
        super.prepare()
        
        backgroundColor = .clear
        
        prepareRouteStopInputViews()
        prepareSearchRouteButton()
        prepareSearchButtonAnimatingImageView()
        prepareSuggestions()
        prepareQueryFieldView()
        prepareQueryField()
        prepareSearchButton()
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
        
        layout(searchRouteButton)
            .right()
            .height(64)
            .width(64)
            .top()
        
        layout(routeStopView)
            .top()
            .left()
            .before(searchRouteButton, 6)
            .height(64)
        
        // Center anchor point
        routeStopView.contentView.layout(routeStopDividerView)
            .top()
            .centerX()
            .width(0)
            .bottom()
        
        routeStopView.contentView.layout(routeStopDepartureInputView)
            .top()
            .left()
            .before(routeStopDividerView, 3)
            .bottom()
        
        routeStopView.contentView.layout(routeStopDestinationInputView)
            .top()
            .right()
            .after(routeStopDividerView, 3)
            .bottom()
        
        layout(queryFieldView)
            .below(routeStopView, 24)
            .left()
            .right()
            .bottom()
        
        queryFieldView.contentView.layout(searchButton)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        
        queryFieldView.contentView.layout(searchButtonAnimatingImageView)
            .right()
            .top()
            .bottom()
            .width(64)
            .height(64)
        
        queryFieldView.contentView.layout(queryField)
            .left(16)
            .top(8)
            .bottom(8)
            .before(searchButton, 12)
            .height(48)
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

extension SearchView {
    
    fileprivate func prepareRouteStopInputViews() {
        routeStopDepartureInputView.stopLabel.text = "Von"
        routeStopDepartureInputView.stopLabel.textColor = Color.grey.base
        routeStopDestinationInputView.stopLabel.text = "Nach"
        routeStopDestinationInputView.stopLabel.textColor = Color.grey.base
    }
    
    fileprivate func prepareSearchRouteButton() {
        searchRouteButton.skeuomorphismView.cornerRadius = 32
        searchRouteButton.skeuomorphismView.lightShadowOpacity = 0.3
        searchRouteButton.pulseColor = Color.blue.base
        searchRouteButton.addTarget(self, action: #selector(searchRoute), for: .touchUpInside)
    }
    
    fileprivate func prepareSearchButtonAnimatingImageView() {
        searchButtonAnimatingImageView.animationImages = (0...89).map {
            UIImage(named: "animation000\($0).png")!
        }
        searchButtonAnimatingImageView.animationDuration = 3
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
    }
    
    fileprivate func prepareSearchButton() {
        searchButton.pulseColor = Color.blue.base
        searchButton.addTarget(self, action: #selector(searchStop), for: .touchUpInside)
    }
    
    fileprivate func prepareQueryField() {
        queryField.delegate = self
        queryField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectQueryField)))
        queryField.font = RobotoFont.light(with: 24)
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
