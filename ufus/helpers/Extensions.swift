//
//  dateExtension.swift
//  ufus
//
//  Created by Akinjide Bankole on 10/10/17.
//  Copyright © 2017 Akinjide Bankole. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func timeDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60, hour = 60 * minute
        let day = 24 * hour, week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second".localized()
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minute".localized()
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour".localized()
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day".localized()
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week".localized()
        } else {
            quotient = secondsAgo / month
            unit = "month".localized()
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "timeSuffix".localized()) \("ago".localized())"
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        
        return dateFormatter.string(from: self)
    }
}

extension String {
    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }
}
