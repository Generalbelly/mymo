//
//  Util.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/08.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation

class Util {
    
    static func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    static func getQueryStringParameter(url: String?, param: String) -> String? {
        if let url = url, let urlComponents = URLComponents(string: url), let queryItems = (urlComponents.queryItems) {
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }
}
