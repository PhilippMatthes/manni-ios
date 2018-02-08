// By: https://github.com/JohnSundell/SwiftTips

import Foundation

extension URL: ExpressibleByStringLiteral {
    // By using 'StaticString' we disable string interpolation, for safety
    public init(stringLiteral value: StaticString) {
        if let url = URL(string: "\(value)") {
            self = url
        } else {
            fatalError("URL Could not be initialized with a string literal of form: \(value)")
        }
    }
}
