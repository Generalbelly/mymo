//
//  Util.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/08.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation

class Util {
    
    static func formatTime(totalSeconds: Int, forParam: Bool) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        if forParam {
            var time = ""
            if hours != 0 {
                time += "\(hours)h"
            }
            if minutes != 0 {
                time += "\(minutes)m"
            }
            if seconds != 0 {
                time += "\(seconds)s"
            }
            return time
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

    }
    
    static func getQueryStringParameter(url: String?, param: String) -> String? {
        if let url = url, let urlComponents = URLComponents(string: url), let queryItems = (urlComponents.queryItems) {
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }
    
    static func convertTimeToDate(timeStamp: TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: timeStamp/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let localDate = dateFormatter.string(from: date as Date)
        return localDate
    }
    
    
    static func getSpeedRate(type: SpeedType) -> Double {
        switch type {
        case .slow:
            return 0.75
        case .normal:
            return 1.0
        case .fast:
            return 1.25
        case .veryFast:
            return 1.5
        case .superFast:
            return 2.0
        }
    }
}
