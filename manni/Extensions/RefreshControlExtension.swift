// From: https://stackoverflow.com/questions/28550021/uirefreshcontrol-not-refreshing-when-triggered-programmatically?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

import Foundation
import UIKit

extension UIRefreshControl {
    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}
