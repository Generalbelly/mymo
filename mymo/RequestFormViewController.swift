//
//  RequestFormViewController.swif.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/18.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Eureka

class RequestFormViewController: FormViewController {
    
    var alertController: UIAlertController! {
        didSet {
            let OKAction = UIAlertAction(title: "Done", style: .default) { [unowned self] action in
                self.dismiss(animated: true, completion: nil)
                if let row = self.form.rowBy(tag: "message") as? TextAreaRow {
                    row.value = ""
                    row.updateCell()
                }
            }
            self.alertController.addAction(OKAction)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Leave feedback"
        form +++ Section(header: "If you have any comments or questions, please send me a message.", footer: "")
            <<< TextAreaRow() { row in
                row.tag = "message"
                row.placeholder = "Enter text here"
            }
            <<< ButtonRow() { row in
                row.title = "Send"
            }
            .onCellSelection { [weak self] cell, row in
                guard let strongSelf = self else { return }
                guard let row = strongSelf.form.rowBy(tag: "message") as? TextAreaRow else { return }
                guard let value = row.value else { return }
                let request = [
                    "message": value,
                ]
                FirebaseClientHelper.shared.push(data: request, path: FirebaseClientHelper.shared.getPath(object: "feedback")!)
                strongSelf.present(strongSelf.alertController, animated: true)
            }
        self.alertController = UIAlertController(title: "Thanks!", message: "Your feedback really helps.", preferredStyle: .alert)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        if let youtubVC = self.parent?.tabBarController?.viewControllers?[0] as? YouTubeViewController {
            youtubVC.menuButton.open()
            youtubVC.menuButton.close()
        }
    }

}

