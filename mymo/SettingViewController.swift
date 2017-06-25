//
//  SettingViewController.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/06/24.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import Firebase

enum Setting: Int {
    case feedback, signIn
}

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadRows(at: [IndexPath(item: 1, section: 0)], with: .automatic)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
    func presentSigninViewController() {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
        ]
        authUI?.providers = providers
        let authViewController = authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.signIn.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting", for: indexPath)
        if indexPath.row == Setting.feedback.rawValue {
            cell.textLabel?.text = "Leave feedback"
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "Sign in"
            cell.textLabel?.textColor = UIColor(colorLiteralRed: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)
            cell.textLabel?.textAlignment = .center
            if Auth.auth().currentUser != nil {
                cell.textLabel?.text = "Sign out"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == Setting.feedback.rawValue {
            self.performSegue(withIdentifier: "rfVC", sender: self)
        } else {
            if Auth.auth().currentUser != nil {
                // User is signed in.
                print("sing out")
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: \(signOutError)")
                }
            } else {
                self.presentSigninViewController()
            }
        }
    }
}

extension SettingViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil {
            self.tableView.reloadRows(at: [IndexPath(item: 1, section: 0)], with: .automatic)
        }
        if let youtubVC = self.tabBarController?.viewControllers?[0] as? YouTubeViewController {
            youtubVC.menuButton.open()
            youtubVC.menuButton.close()
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthViewController(authUI: authUI)
    }
}
