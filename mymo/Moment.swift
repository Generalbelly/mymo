//
//  Memo.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/05.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation

class Moment {

    var videoId: String
    var time: Int
    var title: String
    var content: String
    var addedTime: String
    var updatedTime: String
    var key: String
    
    init(data: [String: Any]) {
        self.videoId = data["videoId"] as! String
        self.time = data["time"] as! Int
        self.title = data["title"] as! String
        self.content = data["content"] as! String
        self.addedTime = Util.convertTimeToDate(timeStamp: data["addedTime"] as! TimeInterval)
        self.updatedTime = Util.convertTimeToDate(timeStamp: data["updatedTime"] as! TimeInterval)
        self.key = data["key"] as! String
    }

    func updateProps(data: [String: Any]) {
        print("updating")
//        self.time = data["time"] as! Int
//        self.title = data["title"] as! String
        self.content = data["content"] as! String
        self.updatedTime = Util.convertTimeToDate(timeStamp: data["updatedTime"] as! TimeInterval)
    }
    
    func toDict() -> [String: Any?] {
        return [
            "videoId": self.videoId,
            "time": self.time,
            "title": self.title,
            "content": self.content,
            "addedTime": self.addedTime,
            "updatedTime": self.updatedTime,
            "key": self.key,
        ]
    }
}
