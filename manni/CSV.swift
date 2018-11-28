//
//  CSV.swift
//  manni
//
//  Created by Philipp Matthes on 19.05.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation

class CSV {
    
    static var cachedCSV: [[String]]?
    static var cachedData: String?
    
    static func csv(data: String) -> [[String]] {
        if cachedCSV != nil {
            return cachedCSV!
        }
        let csv = data.components(separatedBy: "\n")
            .map { $0.components(separatedBy: ";") }
        cachedCSV = csv
        return csv
    }
    
    static func stripRowsFrom(csvString string: String) -> String {
        return string
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\n\n", with: "\n")
    }
    
    static func readDataFromCSV(fileName:String, fileType: String) -> String? {
        if cachedData != nil {
            return cachedData
        }
        guard
            let filepath = Bundle.main.path(forResource: fileName, ofType: fileType),
            let contents = try? String(contentsOfFile: filepath, encoding: .isoLatin1)
        else {return nil}
        let strippedContents = stripRowsFrom(csvString: contents)
        cachedData = strippedContents
        return strippedContents
    }
}
