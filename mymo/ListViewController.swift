//
//  ListViewController.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/10.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import DZNEmptyDataSet
import RealmSwift

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
        }
    }
    var realm: Realm!
    var moments: Results<Moment>!
    var selectedMoment: Moment? = nil
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = try! Realm()
        self.moments = self.realm?.objects(Moment.self)
        self.notificationToken = self.moments.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
        
    deinit {
        self.notificationToken?.stop()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullScreen2" {
            if let vc = segue.destination as? FullsizeViewController {
                vc.moment = self.selectedMoment
            }
        }
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moments.count == 0 {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
        return moments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "moment", for: indexPath as IndexPath) as! ListViewCell
        guard !moments.isEmpty else { return cell }
        let moment = moments[indexPath.row]
        cell.thumbnail!.sd_setShowActivityIndicatorView(true)
        cell.thumbnail!.sd_setIndicatorStyle(.gray)
        cell.thumbnail!.sd_setImage(with: URL(string: "https://img.youtube.com/vi/\(moment.videoId)/mqdefault.jpg"))
        cell.content.text = moment.content
        cell.title!.text = moment.title
        cell.datetime.text = Util.convertTimeToDate(timeStamp: (moment.updatedTime != 0) ? moment.updatedTime : moment.addedTime)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMoment = moments[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "fullScreen2", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { [unowned self] action, index in
            do{
                try self.realm?.write {
                    let moment = self.moments[editActionsForRowAt.row]
                    self.realm!.delete(moment)
                    if self.moments.count == 0 {
                        tableView.reloadEmptyDataSet()
                    }
                }
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
        delete.backgroundColor = .red
        return [delete]
    }

}
extension ListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "Once you mark, it will be available here."
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray,
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(self.navigationController!.navigationBar.frame.size.height) / 2.0
    }

}

