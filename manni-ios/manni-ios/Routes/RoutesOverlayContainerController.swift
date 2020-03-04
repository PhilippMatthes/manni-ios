//
//  RoutesOverlayContainerController.swift
//  manni-ios
//
//  Created by It's free real estate on 29.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material
import DVB


private struct Constants {
    static let minimumHeight: CGFloat = 158
    static let maximumHeight: CGFloat = Screen.height - 356
    static let minimumVelocityConsideration: CGFloat = 50
    static let defaultTranslationDuration: TimeInterval = 0.4
    static let maximumTranslationDuration: TimeInterval = 0.6
}

enum OverlayPosition {
    case maximum, minimum
}

enum OverlayInFlightPosition {
    case minimum
    case maximum
    case progressing
}

class PassThroughView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }

    private func setUpView() {
        backgroundColor = .clear
    }
}


class RoutesOverlayContainerController: ViewController {
    
    public let overlayController = RoutesOverlayController()
    
    public var routeSelectionDelegate: RouteSelectionDelegate?
    
    private lazy var translatedView = UIView()
    private lazy var translatedViewHeightContraint = translatedView.heightAnchor
        .constraint(equalToConstant: Constants.minimumHeight)
    
    private var overlayPosition: OverlayPosition = .minimum
    
    private var translatedViewTargetHeight: CGFloat {
        switch overlayPosition {
        case .maximum:
            return Constants.maximumHeight
        case .minimum:
            return Constants.minimumHeight
        }
    }

    private var overlayInFlightPosition: OverlayInFlightPosition {
        let height = translatedViewHeightContraint.constant
        if height == Constants.maximumHeight {
            return .maximum
        } else if height == Constants.minimumHeight {
            return .minimum
        } else {
            return .progressing
        }
    }
    
    override func loadView() {
        view = PassThroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(translatedView)
        translatedView.pinToSuperview(edges: [.left, .right, .bottom])
        translatedViewHeightContraint.isActive = true
        translatedView.layer.cornerRadius = 32
        
        addChild(overlayController, in: translatedView, edges: [.right, .left, .top])
        overlayController.view.heightAnchor.constraint(equalToConstant: Constants.maximumHeight).isActive = true
        overlayController.overlayDelegate = self
        overlayController.routeSelectionDelegate = self
        
        moveOverlay(to: .maximum)
    }

    func moveOverlay(to position: OverlayPosition) {
        moveOverlay(to: position, duration: Constants.defaultTranslationDuration, velocity: .zero)
    }
    
    private func shouldTranslateView(following scrollView: UIScrollView) -> Bool {
        guard scrollView.isTracking else { return false }
        let offset = scrollView.contentOffset.y
        switch overlayInFlightPosition {
        case .maximum:
            return offset < 0
        case .minimum:
            return offset > 0
        case .progressing:
            return true
        }
    }

    private func translateView(following scrollView: UIScrollView) {
        scrollView.contentOffset = .zero
        let translation = translatedViewTargetHeight - scrollView.panGestureRecognizer.translation(in: view).y
        translatedViewHeightContraint.constant = max(
            Constants.minimumHeight,
            min(translation, Constants.maximumHeight)
        )
    }

    private func animateTranslationEnd(following scrollView: UIScrollView, velocity: CGPoint) {
        let distance = Constants.maximumHeight - Constants.minimumHeight
        let progressDistance = translatedViewHeightContraint.constant - Constants.minimumHeight
        let progress = progressDistance / distance
        let velocityY = -velocity.y * 100
        if abs(velocityY) > Constants.minimumVelocityConsideration && progress != 0 && progress != 1 {
            let rest = abs(distance - progressDistance)
            let position: OverlayPosition
            let duration = TimeInterval(rest / abs(velocityY))
            if velocityY > 0 {
                position = .minimum
            } else {
                position = .maximum
            }
            moveOverlay(to: position, duration: duration, velocity: velocity)
        } else {
            if progress < 0.5 {
                moveOverlay(to: .minimum)
            } else {
                moveOverlay(to: .maximum)
            }
        }
    }

    private func moveOverlay(to position: OverlayPosition,
                             duration: TimeInterval,
                             velocity: CGPoint) {
        overlayPosition = position
        translatedViewHeightContraint.constant = translatedViewTargetHeight
        UIView.animate(
            withDuration: min(duration, Constants.maximumTranslationDuration),
            delay: 0,
            usingSpringWithDamping: velocity.y == 0 ? 1 : 0.6,
            initialSpringVelocity: abs(velocity.y),
            options: [.allowUserInteraction],
            animations: {
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension RoutesOverlayContainerController: RoutesOverlayControllerDelegate {    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldTranslateView(following: scrollView) else { return }
        translateView(following: scrollView)
    }

    func scrollView(
        _ scrollView: UIScrollView,
        willEndScrollingWithVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        switch overlayInFlightPosition {
        case .maximum:
            break
        case .minimum, .progressing:
            targetContentOffset.pointee = .zero
        }
        animateTranslationEnd(following: scrollView, velocity: velocity)
    }
}

extension RoutesOverlayContainerController: RouteSelectionDelegate {
    func didSelect(route: Route) {
        moveOverlay(to: .minimum)
        routeSelectionDelegate?.didSelect(route: route)
    }
}
