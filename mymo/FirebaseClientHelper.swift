//
//  FirebaseClientHelper.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/10.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class FirebaseClientHelper {

    private init() {
        self.ref = Database.database().reference()
    }
    static let shared = FirebaseClientHelper()
    var ref: DatabaseReference!
//    var momentRef: DatabaseReference!
//    var user: User?
    
//    func fetch(path: String, completionHandler: @escaping (DataSnapshot?) -> ()) {
//        self.ref.child(path).observe(.childAdded, with: { snapshot in
//            completionHandler(snapshot)
//        })
//        self.ref.child(path).observe(.childChanged, with: { snapshot in
//            completionHandler(snapshot)
//        })
//    }
//    
//    func fetchOnce(path: String, completionHandler: @escaping ([String: Any]?) -> ()) {
//        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot.value!)
//            completionHandler(snapshot.value! as? [String: Any])
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }

    func push(data: [String: Any?], path: String) {
        let timestamp = ServerValue.timestamp()
        var data = data
        let uid = self.ref.childByAutoId().key
        data["key"] = uid
        data["addedTime"] = timestamp
        self.ref.child(path).child(uid).setValue(data)
    }
    
//    func update(data: Any, path: String) {
//        self.ref.child(path).setValue(data)
//    }

//    func delete(path: String, completionHandler: @escaping (Bool) -> ()) {
//        self.ref.child(path).removeValue(completionBlock: { error, _ in
//            if error != nil {
//                completionHandler(false)
//            } else {
//                completionHandler(true)
//            }
//        })
//    }
    
    func getPath(object: String) -> String? {
        if object == "feedback" {
            return "feedback"
        }
        return nil
    }

}
