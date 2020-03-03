//
//  Departure+FancyETA.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 10.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB


// Todo: refactor this pile of duplicated code


extension Departure {
    
    public var manniLatency: String? {
        get {
            guard let realTime = realTime else {return nil}
            let diff = Int(realTime.timeIntervalSince(scheduledTime) / 60)
            guard diff != 0 else {return nil}
            if diff > 0 {
                return "\(diff) Min. verspätet"
            } else {
                return "\(abs(diff)) Min. zu früh"
            }
        }
    }
    
    public var manniETA: String {
        get {
            let time = realTime ?? scheduledTime
            let interval = Calendar.current.dateComponents([
                .minute, .second
            ], from: Date(), to: time)
            
            if let minutes = interval.minute, minutes >= 20 || minutes <= -20 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                return dateFormatter.string(from: time)
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
                .minute, .second
            ], from: Date(), to: time)
            
            if let minutes = interval.minute, minutes >= 20 || minutes <= -20 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                return dateFormatter.string(from: time)
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


extension Date {
    public var etaString: String {
        get {
            let interval = Calendar.current.dateComponents([
                .minute, .second
            ], from: Date(), to: self)
            
            if let minutes = interval.minute, minutes >= 20 || minutes <= -20 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                return dateFormatter.string(from: self)
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
    
    public var shortETAString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
        }
    }
}


extension Route {
    
    public var manniDepartureETA: String {
        get {
            guard let time = partialRoutes.first?.regularStops?.first?.departureTime else {return "n/a"}
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: time)
        }
    }
    
    public var manniArrivalETA: String {
        get {
            guard let time = partialRoutes.last?.regularStops?.last?.arrivalTime else {return "n/a"}
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: time)
        }
    }
    
}
