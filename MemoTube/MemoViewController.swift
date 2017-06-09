//
//  MemoViewController.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/04.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import UIKit

class MemoViewController: UIViewController {
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveTapped(_ sender: Any) {
        self.present(self.alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            self.textView.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10)
            self.textView.becomeFirstResponder()
        }
    }
    var alertController: UIAlertController!
    
    var memo: Memo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alertController = UIAlertController(title: "Save", message: "You can optionally name this memo", preferredStyle: UIAlertControllerStyle.alert)
        self.alertController.addTextField { textField in
          //  textField.text = self.memo.title
        }
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            self.memo.content = self.textView.text
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.alertController.addAction(cancelAction)
        self.alertController.addAction(doneAction)
    }

}
