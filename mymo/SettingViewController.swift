//
//  SettingViewController.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/24.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import UIKit

enum Setting: Int {
    case feedback
    case faq
}

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == Setting.feedback.rawValue {
            cell.textLabel?.text = "Leave feedback"
        } else if indexPath.row == Setting.faq.rawValue {
            cell.textLabel?.text = "FAQ"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == Setting.feedback.rawValue {
            self.performSegue(withIdentifier: "rfVC", sender: self)
        } else if indexPath.row == Setting.faq.rawValue {
            self.performSegue(withIdentifier: "faq", sender: self)
        }
    }

}
