//
//  AlgoliaClient.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/10.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import AlgoliaSearch

class AlgoliaClient {

    let client = Client(appID: "MIAR07XWNL", apiKey: "0ada363b86086882e1a5fa84eddebb91")
    
    private init() { }
    static let shared = AlgoliaClient()
    
    func push(data: String) {
        let jsonData = try! Data(base64Encoded: data)
        let script = try! JSONSerialization.jsonObject(with: jsonData!)
        // Load all objects in the JSON file into an index named "contacts".
        let index = client.index(withName: "scripts")
        index.addObjects(script as! [JSONObject])
    }
    
}
