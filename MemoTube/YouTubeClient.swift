//
//  YouTubeClient.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/08.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SWXMLHash

final class YouTubeClient {
    
    private init() { }
    static let shared = YouTubeClient()

    let baseUrl = "http://video.google.com/timedtext"
//    let baseUrl = "https://www.googleapis.com/youtube/v3/"
    let lang = "en"
    var accessToken = ""
//    var ccList: [String] = []
//    var ccTrackName: String?
    
    func fetchCaptionId(videoId: String, completionHandler:@escaping (String?) -> ()) {
        let params = [
            "type": "list",
            "v": videoId,
            ]
        self.request(parameters: params) { data in
            if data != nil {
                //<transcript_list docid="xxxxxxxxxxxxxxxxxx">
//                <track id="0" name="hogehoge" lang_code="en" lang_original="English" lang_translated="English" lang_default="true"/>
//                <track id="1" name="ほげほげ" lang_code="ja" lang_original="日本語" lang_translated="Japanese"/>
//                </transcript_list>
//                
                let xml = SWXMLHash.lazy(data!)
                let caption = xml["transcript_list"]["track"].all.filter{ elem in elem.attribute(by: "lang_code")?.text == "en"}[0]
                print(caption)
            }
            completionHandler(nil)
        }
//        let params = [
//            "part": "snippet",
//            "videoId": videoId,
//        ]
//        self.request(endpoint: "captions", parameters: params) { data in
//            if data != nil {
//                let json = JSON(data!)
//                if let items = json["items"].array {
//                    if items.count > 0 {
//                        let captionId = items.filter({ item in item["snippet"]["language"] == "en" })[0]["id"].string
//                        completionHandler(captionId!)
//                    }
//                }
//            }
//            completionHandler(nil)
//        }
    }
    
    func fetchCaption(captionId: String) {
        let params = [
            "tfmt": "ttml"
            
        ]
        self.request(parameters: params) { data in
        }
    }
    
    func request(parameters: [String: String]?, completionHandler:@escaping (Data?) -> ()) {
        Alamofire.request(self.baseUrl,  parameters: parameters).responseData { response in
            if let data = response.result.value {
                print("Data: \(data)")
                completionHandler(data)
            } else {
                completionHandler(nil)
            }
        }
    }
    
//    func request(endpoint: String, parameters: [String: String]?, completionHandler:@escaping (Any?) -> ()) {
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(self.accessToken)",
//            "Accept": "application/json"
//        ]
//        Alamofire.request(self.baseUrl + endpoint,  parameters: parameters, headers: headers).responseJSON { response in
//            print("Request: \(response.request)")
//            print("Response: \(response.response)")
//            print("Error: \(response.error)")
//            if let data = response.result.value {
//                print("Data: \(data)")
//                completionHandler(data)
//            } else {
//                completionHandler(nil)
//            }
//        }
//    }
}
