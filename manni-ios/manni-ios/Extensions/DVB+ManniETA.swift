//
//  Departure+FancyETA.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 10.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB

extension Departure {
    
    public var manniETA: String {
        get {
            let time = realTime ?? scheduledTime
            let interval = Calendar.current.dateComponents([
                .hour, .minute, .second
            ], from: Date(), to: time)
            
            if let hours = interval.hour, hours != 0 {
                if hours > 0 {
                    return hours == 1 ? "In 1 Stunde" : "In \(hours) Stunden"
                } else {
                    return hours == -1 ? "Vor 1 Stunde": "Vor \(abs(hours)) Stunden"
                }
            }
            
            if let minutes = interval.minute, minutes != 0 {
                if minutes > 0 {
                    return minutes == 1 ? "In 1 Minute" : "In \(minutes) Minuten"
                } else {
                    return minutes == -1 ? "Vor 1 Minute": "Vor \(abs(minutes)) Minuten"
                }
            }
            
            if let seconds = interval.second, seconds != 0 {
                if seconds > 0 {
                    return seconds == 1 ? "In 1 Sekunde" : "In \(seconds) Sekunden"
                } else {
                    return seconds == -1 ? "Vor 1 Sekunde": "Vor \(abs(seconds)) Sekunden"
                }
            }
            
            return "Jetzt"
        }
    }
    
}

extension TripStop {
    
    public var manniETA: String {
        get {
            let interval = Calendar.current.dateComponents([
                .hour, .minute, .second
            ], from: Date(), to: time)
            
            if let hours = interval.hour, hours != 0 {
                if hours > 0 {
                    return hours == 1 ? "In 1 Stunde" : "In \(hours) Stunden"
                } else {
                    return hours == -1 ? "Vor 1 Stunde": "Vor \(abs(hours)) Stunden"
                }
            }
            
            if let minutes = interval.minute, minutes != 0 {
                if minutes > 0 {
                    return minutes == 1 ? "In 1 Minute" : "In \(minutes) Minuten"
                } else {
                    return minutes == -1 ? "Vor 1 Minute": "Vor \(abs(minutes)) Minuten"
                }
            }
            
            if let seconds = interval.second, seconds != 0 {
                if seconds > 0 {
                    return seconds == 1 ? "In 1 Sekunde" : "In \(seconds) Sekunden"
                } else {
                    return seconds == -1 ? "Vor 1 Sekunde": "Vor \(abs(seconds)) Sekunden"
                }
            }
            
            return "Jetzt"
        }
    }
    
}
