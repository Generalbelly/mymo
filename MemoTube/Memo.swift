//
//  Memo.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/05.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation

class Memo {

    var time: Int
    var title: String
    var content: String
    
    init(time: Int, title: String, content: String) {
        self.time = time
        self.title = title
        self.content = content
    }

}
