// By: https://github.com/JohnSundell/SwiftTips

import Foundation
import CoreGraphics

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
