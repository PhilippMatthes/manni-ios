// This code belongs to https://github.com/JohnSundell/SwiftTips

import Foundation

extension Equatable {
    func isAny(of candidates: Self...) -> Bool {
        return candidates.contains(self)
    }
}
