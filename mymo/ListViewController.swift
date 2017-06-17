//
//  ListViewController.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/10.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import DZNEmptyDataSet

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    var memos: [Memo] = []
    var selectedMemo: Memo?
    var reservedMemo: [String: Any]?
    
    var alertController: UIAlertController! {
        didSet {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                DispatchQueue.global(qos: .userInitiated).async {
                    FirebaseClientHelper.shared.delete(path: "\(FirebaseClientHelper.shared.getPath(object: "memo")!)/\((self.reservedMemo!["memo"] as! Memo).key!)") { result in
                        if result {
                            DispatchQueue.main.async {
                                self.memos.remove(at: (self.reservedMemo!["index"] as! IndexPath).row)
                                self.tableView.deleteRows(at: [self.reservedMemo!["index"] as! IndexPath], with: UITableViewRowAnimation.automatic)
                            }
                        }
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            }
            self.alertController.addAction(deleteAction)
            self.alertController.addAction(cancelAction)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        DispatchQueue.global(qos: .userInitiated).async {
            FirebaseClientHelper.shared.fetch(path: FirebaseClientHelper.shared.getPath(object: "memo")!) { snapshot in
                if snapshot != nil {
                    DispatchQueue.main.async {
                        let filterdMemos = self.memos.filter({ memo in memo.key == snapshot!.key })
                        var memo: Memo!
                        if filterdMemos.count > 0 {
                            memo = filterdMemos.first
                            memo.updateProps(data: snapshot!.value as! [String: Any])
                        } else {
                            memo = Memo(data: snapshot!.value as! [String: Any])
                            memo.key = snapshot!.key
                            self.memos.append(memo)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        alertController = UIAlertController(title: "Delete", message: "Once you do it, you can't undo this action", preferredStyle: .alert)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memos.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "memo", for: indexPath as IndexPath) as! ListViewCell
        if !memos.isEmpty {
            let memo = memos[indexPath.row]
            cell.thumbnail!.sd_setShowActivityIndicatorView(true)
            cell.thumbnail!.sd_setIndicatorStyle(.gray)
            cell.thumbnail!.sd_setImage(with: URL(string: "https://img.youtube.com/vi/\(memo.videoId)/mqdefault.jpg"))
            cell.title!.text = memo.title
            if memo.content.characters.count > 10 {
                cell.content.text = memo.content.substring(to: memo.content.index(memo.content.startIndex, offsetBy: 10))
            } else {
                cell.content.text = memo.content
            }
            cell.datetime.text = memo.updatedTime
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMemo = memos[indexPath.row]
        self.performSegue(withIdentifier: "ytVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.reservedMemo = [
                "index": index,
                "memo": self.memos[index.row]
            ]
            self.present(self.alertController, animated: true)
        }
        delete.backgroundColor = .red
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ytVC" {
            if let vc = segue.destination as? YouTubeViewController {
                vc.memo = self.selectedMemo
            }
        }
    }
}

extension ListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        
//    }
//    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "Once you save a memo, it is available here."
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray,
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}
