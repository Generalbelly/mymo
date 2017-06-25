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
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
        }
    }
    
    var moments: [Moment] = []
    var selectedMoment: Moment?
    var reservedMoment: [String: Any]?
    
    var alertController: UIAlertController! {
        didSet {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let strongSelf = self else { return }
                FirebaseClientHelper.shared.delete(path: "\(FirebaseClientHelper.shared.getPath(object: "moment")!)/\((strongSelf.reservedMoment!["moment"] as! Moment).key)") { result in
                    if result {
                        strongSelf.moments.remove(at: (strongSelf.reservedMoment!["index"] as! IndexPath).row)
                        strongSelf.tableView.deleteRows(at: [strongSelf.reservedMoment!["index"] as! IndexPath], with: UITableViewRowAnimation.automatic)
                    }
                }
                strongSelf.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [unowned self] action in
                self.dismiss(animated: true, completion: nil)
            }
            self.alertController.addAction(deleteAction)
            self.alertController.addAction(cancelAction)
        }
    }
    
    var emptyStateUpdated = false
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertController = UIAlertController(title: "Delete", message: "Once you do it, you can't undo this action", preferredStyle: .alert)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if (user != nil) {
                FirebaseClientHelper.shared.user = user
                FirebaseClientHelper.shared.fetch(path: FirebaseClientHelper.shared.getPath(object: "moment")!) { [weak self] snapshot in
                    guard let strongSelf = self else { return }
                    if snapshot != nil {
                        var moment = strongSelf.moments.first(where:{$0.key == snapshot!.key})
                        if (moment != nil) {
                            moment!.updateProps(data: snapshot!.value as! [String: Any])
                            strongSelf.tableView.reloadRows(at: [IndexPath(item: strongSelf.moments.index{$0 === moment}!, section: 0)], with: .automatic)
                        } else {
                            moment = Moment(data: snapshot!.value as! [String: Any])
                            strongSelf.moments.append(moment!)
                            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.moments.count-1, section: 0)], with: .automatic)
                            if !strongSelf.emptyStateUpdated {
                                strongSelf.tableView.reloadEmptyDataSet()
                                strongSelf.emptyStateUpdated = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
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
        cell.datetime.text = moment.updatedTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMoment = moments[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "ytVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { [unowned self] action, index in
            self.reservedMoment = [
                "index": index,
                "moment": self.moments[index.row]
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
                vc.moment = self.selectedMoment
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
        let string = "Once you mark, it will be available here."
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray,
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}

extension ListViewController: FUIAuthDelegate {

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // Here is where we add code after logging in
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthViewController(authUI: authUI)
    }
}
