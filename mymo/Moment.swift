//
//  Memo.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/05.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import RealmSwift

class Moment: Object {

    dynamic var videoId = ""
    dynamic var time = 0
    dynamic var title = ""
    dynamic var content = ""
    dynamic var addedTime: Double = 0
    dynamic var updatedTime: Double = 0

}
