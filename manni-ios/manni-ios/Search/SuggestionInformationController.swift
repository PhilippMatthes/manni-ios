//
//  SuggestionInformationController.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 08.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material

class SuggestionInformationController: ViewController {
    
    fileprivate let backButton = SkeuomorphismIconButton(image: Icon.arrowBack, tintColor: Color.grey.darken4)
    fileprivate let titleLabel = UILabel()
    fileprivate let explanationLabel = UILabel()
    fileprivate let exampleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("#ECE9E6")
        
        view.layout(backButton)
            .top(24)
            .left(24)
            .height(64)
            .width(64)
        backButton.pulseColor = Color.blue.base
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        
        view.layout(titleLabel)
            .below(backButton, 24)
            .left(24)
            .right(24)
        titleLabel.font = RobotoFont.bold(with: 24)
        titleLabel.textColor = Color.grey.darken4
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = "Wie funktioniert die Haltestellenvorhersage?"
        
        view.layout(explanationLabel)
            .below(titleLabel, 8)
            .left(24)
            .right(24)
        explanationLabel.font = RobotoFont.light(with: 18)
        explanationLabel.textColor = Color.grey.darken2
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.text = "Jedes Mal, wenn Du eine Haltestelle auswählst, " +
                                "speichert Dein Gerät dies lokal ab. Du behältst " +
                                "also die volle Kontrolle über Deine Daten. " +
                                "Die App <komplizierte Erklärung des Algorithmus hier einfügen> " +
                                "sagt dann vorher, welche Haltestelle Du als nächstes anfragen " +
                                "könntest."
        
        view.layout(exampleLabel)
            .below(explanationLabel, 16)
            .left(24)
            .right(24)
        exampleLabel.font = RobotoFont.regular(with: 12)
        exampleLabel.textColor = Color.grey.darken2
        exampleLabel.numberOfLines = 0
        exampleLabel.lineBreakMode = .byWordWrapping
        exampleLabel.text = computeExampleText()
    }
    
    func computeExampleText() -> String {
        let graph = RouteGraph.main
        if let lastStop = graph.endpoint {
            var text = "Du warst zuletzt an der Haltestelle \(lastStop.name).\n"
            let edges = graph.edges
                .filter {$0.origin == lastStop}
                .sorted {$0.weight > $1.weight}
            if edges.count == 0 {
                return text +   "Die App hat aber noch keine Informationen zu dieser Haltestelle und kann Dir " +
                                "daher noch keine Vorschläge geben."
            } else {
                text += "Nachdem Du diese Haltestelle gesucht hast, suchtest Du "
                if edges.count == 1 {
                    text += "\(edges.first!.weight) mal nach der Haltestelle \(edges.first!.destination.name)."
                } else {
                    let firstEdges = edges.prefix(edges.count - 1)
                    let lastEdge = edges.last!
                    text += firstEdges
                        .map {"\($0.weight) mal nach der Haltestelle \($0.destination.name)"}
                        .joined(separator: ", ")
                    text += " und \(lastEdge.weight) mal nach der Haltestelle \(lastEdge.destination.name)."
                }
                text += "\nDie App geht deshalb davon aus, dass Du am Wahrscheinlichsten als nächstes nach der Haltestelle \(edges.first!.destination.name) suchen wirst. Die App zeigt Dir deshalb diese Haltestelle als obersten Vorschlag an."
                return text
            }
        } else {
            return "Besuche ein paar Haltestellen und komm wieder, um Dir ein Beispiel anzeigen zu lassen!"
        }
    }
    
    @objc func backButtonTouched() {
        self.dismiss(animated: true)
    }
    
}
