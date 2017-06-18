//
//  YouTubeClient.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/08.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

final class YouTubeClient {
  
    let baseUrl = "http://video.google.com/timedtext"
    let lang = "en"
    
    private init() { }
    static let shared = YouTubeClient()

    func fetchCaptionName(videoId: String, completionHandler:@escaping (String?) -> ()) {
        let params = [
            "type": "list",
            "v": videoId,
            ]
        self.request(parameters: params) { data in
            if data != nil {
                let xml = SWXMLHash.lazy(data!)
                let tracks = xml["transcript_list"]["track"].all
                if !tracks.isEmpty {
                    let captions = tracks.filter{ elem in elem.element?.attribute(by: "lang_code")?.text == self.lang}
                    if !captions.isEmpty {
                        completionHandler(captions[0].element?.attribute(by: "name")?.text)
                    }
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func fetchCaption(videoId: String, name: String, completionHandler:@escaping ([[String: String]]?) -> ()) {
        let params = [
            "lang": "en",
            "name": name,
            "v": videoId,
        ]
        self.request(parameters: params) { data in
            if data != nil {
                let xml = SWXMLHash.lazy(data!)
                let rawTexts = xml["transcript"]["text"].all
                if !rawTexts.isEmpty {
                    let texts = rawTexts.map({ elem -> [String : String] in
                        let time = elem.element!.attribute(by: "start")!.text
                        let text = elem.element!.text
                        return ["text": text, "time": time]
                    })
                    completionHandler(texts)
                } else {
                    completionHandler(nil)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func request(parameters: [String: String]?, completionHandler:@escaping (Data?) -> ()) {
        Alamofire.request(self.baseUrl,  parameters: parameters).responseData { response in
            if let data = response.result.value {
                completionHandler(data)
            } else {
                completionHandler(nil)
            }
        }
    }
}
