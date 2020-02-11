//
//  TripViewCell.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 10.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Material
import DVB
import Motion


protocol TripTableViewCellDelegate {
    func shouldScroll(to indexPath: IndexPath)
}


class TripTableViewCell: UITableViewCell {
    
    public static let reuseIdentifier = "TripTableViewCell"
    
    public var previousTripStop: TripStop?
    public var tripStop: TripStop? {
        didSet {
            guard let tripStop = tripStop else {return}
            stopNameLabel.text = tripStop.name
            etaLabel.text = tripStop.manniETA
            
            if tripStop.time.timeIntervalSinceNow >= 0 {
                scrollTimer?.invalidate()
                scrollTimer = Timer(
                    fireAt: tripStop.time,
                    interval: 0,
                    target: self,
                    selector: #selector(shouldScroll),
                    userInfo: nil,
                    repeats: false
                )
                RunLoop.main.add(scrollTimer!, forMode: .common)
            }
            
            updateTimeResponsiveUI()
        }
    }
    
    public var nextTripStop: TripStop?
    
    public var indexPath: IndexPath?
    public var delegate: TripTableViewCellDelegate?
    
    fileprivate let progressView = VerticalProgressBarView()
    fileprivate let dotButton = SkeuomorphismView()
    fileprivate var timeResponsiveRefreshTimer: Timer?
    fileprivate var scrollTimer: Timer?
    fileprivate let stopNameLabel = UILabel()
    fileprivate let etaLabel = UILabel()
    
    fileprivate var progress: CGFloat {
        get {
            guard
                let tripStop = tripStop
                else {return 0.0}
            
            let previousSeconds = previousTripStop?.time.timeIntervalSince1970 ?? tripStop.time.timeIntervalSince1970
            let targetSeconds = tripStop.time.timeIntervalSince1970
            let seconds = Date().timeIntervalSince1970
            let nextSeconds = nextTripStop?.time.timeIntervalSince1970 ?? tripStop.time.timeIntervalSince1970
            
            let fromSeconds = previousSeconds + ((targetSeconds - previousSeconds) / 2)
            let toSeconds = targetSeconds + ((nextSeconds - targetSeconds) / 2)
            
            if fromSeconds > seconds {
                return 0
            } else if seconds > toSeconds {
                return 100
            } else {
                let progress = (seconds - fromSeconds) / (toSeconds - fromSeconds)
                return CGFloat(progress * 100)
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        prepare()
    }
    
    func prepare() {
        backgroundColor = .clear
        
        timeResponsiveRefreshTimer = .scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimeResponsiveUI),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timeResponsiveRefreshTimer!, forMode: .common)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layout(progressView)
            .left(30)
            .top()
            .width(4)
            .bottom()
        progressView.transform = .init(rotationAngle: CGFloat.pi)
        progressView.progressBackgroundColor = Color.white.withAlphaComponent(0.3)
        progressView.progressBarColor = Color.white
        
        contentView.layout(dotButton)
            .left(24)
            .width(16)
            .height(16)
            .centerY()
        dotButton.cornerRadius = 8
        dotButton.lightColor = Color.grey.lighten4
        dotButton.lightShadowOpacity = 0.2
        
        contentView.layout(stopNameLabel)
            .after(progressView, 24)
            .centerY()
            .right(24)
        stopNameLabel.font = RobotoFont.regular(with: 24)
        stopNameLabel.textColor = .white
        stopNameLabel.numberOfLines = 0
        
        contentView.layout(etaLabel)
            .after(progressView, 24)
            .below(stopNameLabel, 8)
            .right(24)
        etaLabel.font = RobotoFont.light(with: 12)
        etaLabel.textColor = .white
        etaLabel.numberOfLines = 0
    }
    
    @objc func updateTimeResponsiveUI() {
        let computedProgress = progress
        progressView.progress = computedProgress
        
        etaLabel.text = "Abfahrt nach Fahrplan: \(tripStop?.manniETA ?? "Unbekannt")"
        
        if computedProgress == 100.0 || computedProgress >= 50.0 {
            dotButton.transform = .init(scaleX: 1.0, y: 1.0)
        } else {
            dotButton.transform = .init(scaleX: 0.5, y: 0.5)
        }
    }
    
    @objc func shouldScroll() {
        guard let indexPath = indexPath else {return}
        delegate?.shouldScroll(to: indexPath)
        
        UIView.animate(withDuration: 1.0) {
            self.dotButton.transform = .init(scaleX: 0.5, y: 0.5)
        }
    }
    
}

