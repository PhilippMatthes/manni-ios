//
//  Search.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 06.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation


struct FeatureSet: Codable {
    let lastQuery: String
    let date: Date
    
    private enum CodingKeys: String, CodingKey {
        case lastQuery
        case date
    }
    
    init() {
        if let lastSearch = Search.all.last {
            self.lastQuery = lastSearch.query
        } else {
            self.lastQuery = ""
        }
        self.date = Date()
    }
    
    var features: [Int] {
        get {
            return [
                lastQuery.hashValue,
                Calendar.current.component(.weekday, from: date)
            ]
        }
    }
}


struct Search: Codable {
    let query: String
    let featureSet: FeatureSet
    
    private enum CodingKeys: String, CodingKey {
        case query
        case featureSet
    }
    
    init(query: String) {
        self.query = query
        self.featureSet = FeatureSet()
    }
    
    private static var backingAll: [Search]?
    public static var all: [Search] {
        get {
            if let backingAll = backingAll {
                return backingAll
            }
            guard
                let data = UserDefaults.standard.object(forKey: "searches") as? Data,
                let subscribed = try? JSONDecoder().decode([Search].self, from: data)
                else {
                    backingAll = [Search]()
                    return backingAll!
            }
            backingAll = subscribed
            return backingAll!
        }
        set {
            backingAll = newValue
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "searches")
        }
    }
    
    public func save() {
        Search.all.append(self)
    }
    
    public static func predictQuery(completion: @escaping (String?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            var featureSets = [[Int]]()
            var targetQueries = [String]()
            for search in Search.all {
                featureSets.append(search.featureSet.features)
                targetQueries.append(search.query)
            }
            do {
                let classifier = try NaiveBayes(type: .multinomial, data: featureSets, classes: targetQueries)
                try classifier.train()
                completion(classifier.classify(with: FeatureSet().features))
            } catch {
                print("Classifier could not be trained")
                completion(nil)
            }
        }
    }
    
}
