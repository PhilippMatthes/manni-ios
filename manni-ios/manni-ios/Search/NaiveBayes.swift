//

//    Copyright (c) 2016 Matthijs Hollemans and contributors
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

//  NaiveBayes.swift
//  NaiveBayes
//
//  Created by Philipp Gabriel on 14.04.17.
//  Copyright © 2017 ph1ps. All rights reserved.
//
import Foundation

extension String: Error {}

extension Array where Element == Double {

    func mean() -> Double {
        return self.reduce(0, +) / Double(count)
    }

    func standardDeviation() -> Double {
        let calculatedMean = mean()

        let sum = self.reduce(0.0) { (previous, next) in
            return previous + pow(next - calculatedMean, 2)
        }

        return sqrt(sum / Double(count - 1))
    }
}

extension Array where Element == Int {

    func uniques() -> Set<Element> {
        return Set(self)
    }

}

public enum NBType {

    case gaussian
    case multinomial

    
    func calcLikelihood(variables: [Any], input: Any) -> Double? {

        if case .gaussian = self {

            guard let input = input as? Double else {
                return nil
            }

            guard let mean = variables[0] as? Double else {
                return nil
            }

            guard let stDev = variables[1] as? Double else {
                return nil
            }

            let eulerPart = pow(M_E, -1 * pow(input - mean, 2) / (2 * pow(stDev, 2)))
            let distribution = eulerPart / sqrt(2 * .pi) / stDev

            return distribution

        } else if case .multinomial = self {

            guard let variables = variables as? [(category: Int, probability: Double)] else {
                return nil
            }

            guard let input = input as? Int else {
                return nil
            }

            return variables.first { variable in
                return variable.category == input
                }?.probability

        }

        return nil
    }

    func train(values: [Any]) -> [Any]? {

        if case .gaussian = self {

            guard let values = values as? [Double] else {
                return nil
            }

            return [values.mean(), values.standardDeviation()]

        } else if case .multinomial = self {

            guard let values = values as? [Int] else {
                return nil
            }

            let count = values.count
            let categoryProba = values.uniques().map { value -> (Int, Double) in
                return (value, Double(values.filter { $0 == value }.count) / Double(count))
            }
            return categoryProba
        }

        return nil
    }
}

public class NaiveBayes {

    var variables: [String: [(feature: Int, variables: [Any])]]
    var type: NBType

    var data: [[Int]]
    var classes: [String]

    public init(type: NBType, data: [[Int]], classes: [String]) throws {
        self.type = type
        self.data = data
        self.classes = classes
        self.variables = [String: [(Int, [Any])]]()
    }

    @discardableResult public func train() throws -> Self {

        for `class` in Set(classes) {
            variables[`class`] = [(Int, [Any])]()

            let classDependent = data.enumerated().filter { (offset, _) in
                return classes[offset] == `class`
            }

            for feature in 0..<data[0].count {

                let featureDependent = classDependent.map { $0.element[feature] }

                guard let trained = type.train(values: featureDependent) else {
                    throw "Critical! Data could not be casted even though it was checked at init"
                }

                variables[`class`]?.append((feature, trained))
            }
        }

        return self
    }

    public func classify(with input: [Int]) -> String? {
        let likelihoods = classifyProba(with: input).max { (first, second) -> Bool in
            return first.1 < second.1
        }

        guard let `class` = likelihoods?.0 else {
            return nil
        }

        return `class`
    }

    public func classifyProba(with input: [Int]) -> [(String, Double)] {

        var probaClass = [String: Double]()
        let amount = classes.count

        classes.forEach { `class` in
            let individual = classes.filter { $0 == `class` }.count
            probaClass[`class`] = Double(individual) / Double(amount)
        }

        let classesAndFeatures = variables.map { (`class`, value) -> (String, [Double]) in
            let distribution = value.map { (feature, variables) -> Double in
                return type.calcLikelihood(variables: variables, input: input[feature]) ?? 0.0
            }
            return (`class`, distribution)
        }

        let likelihoods = classesAndFeatures.map { (`class`, distribution) in
            return (`class`, distribution.reduce(1, *) * (probaClass[`class`] ?? 0.0))
        }

        let sum = likelihoods.map { $0.1 }.reduce(0, +)
        let normalized = likelihoods.map { (`class`, likelihood) in
            return (`class`, likelihood / sum)
        }

        return normalized
    }
}
