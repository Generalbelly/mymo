//
//  FirebaseClientHelper.swift
//  MemoTube
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
    var memoRef: DatabaseReference!
    var user: User?
    
    func fetch(path: String, completionHandler: @escaping (DataSnapshot?) -> ()) {
        self.ref.child(path).observe(.childAdded, with: { snapshot in
            completionHandler(snapshot)
        })
        self.ref.child(path).observe(.childChanged, with: { snapshot in
            completionHandler(snapshot)
        })
    }
    
    func push(data: [String: Any?], path: String) {
        self.ref.child(path).childByAutoId().setValue(data)
    }
    
    func update(data: Any, path: String) {
        self.ref.child(path).setValue(data)
    }

    func delete(path: String, completionHandler: @escaping (Bool) -> ()) {
        self.ref.child(path).removeValue(completionBlock: { error, _ in
            if error != nil {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
    }
    
    func getPath(object: String) -> String? {
        if object == "memo" {
            return "memos/\(self.user!.uid)"
        }
        return nil
    }

}
