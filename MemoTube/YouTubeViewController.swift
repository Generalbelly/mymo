//
//  YouTubeViewController.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/02.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Floaty
import JavaScriptCore
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import Firebase
import GoogleSignIn

enum SpeedType: Int {
    case slow, normal, fast, veryFast, superFast
}

enum MovingDirection {
    case back, forward
}

class YouTubeViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var menuButton: Floaty! {
        didSet {
            self.addOptionsToMenu()
            self.menuButton.autoCloseOnTap = false
        }
    }
    
    // YouTube
    var webView: WKWebView! {
        didSet {
            self.webView.uiDelegate = self
            self.webView.navigationDelegate = self
            self.view.insertSubview(self.webView!, at: 0)
            let url = URL(string: "https://www.youtube.com/")
            self.webView.load(URLRequest(url: url!))
        }
    }
    
    @IBOutlet weak var forwardButton: UIButton! {
        didSet {
            self.forwardButton.clipsToBounds = true
            self.forwardButton.layer.cornerRadius = 0.5 * self.forwardButton.bounds.size.width
        }
    }
    @IBAction func forwardButtonTapped(_ sender: Any) {
        self.move(direction: .forward)
    }

    @IBOutlet weak var backButton: UIButton! {
        didSet {
            self.backButton.clipsToBounds = true
            self.backButton.layer.cornerRadius = 0.5 * self.backButton.bounds.size.width
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.move(direction: .back)
    }
    
    var alertController: UIAlertController! {
        didSet {
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            }
            self.alertController.addAction(OKAction)
        }
    }
    var saveAlertController: UIAlertController! {
        didSet {
            self.saveAlertController.addTextField { textField in
                textField.placeholder = self.webView.title
            }
            let doneAction = UIAlertAction(title: "Save", style: .default, handler: { action in
                let memo = Memo(time: self.pausedTime, title: self.webView.title ?? "", content: self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
                print(self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
                print("test")
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            self.saveAlertController.addAction(cancelAction)
            self.saveAlertController.addAction(doneAction)
        }
    }

    // Video property
    var speedType: SpeedType = .normal
    var pausedTime = 0
    
    // Memo
    var memo: Memo?
    var textView: UITextView! {
        didSet {
            self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
            self.textView.layer.borderColor = UIColor.lightGray.cgColor
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.characters.count - 1, 0))
            self.textView.layer.borderWidth = 1
            self.textView.isHidden = true
            
            // Keyboard toolbar
            let keyboardToolbar = UIToolbar()
            keyboardToolbar.sizeToFit()
            let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.keyboardCancalTapped))
            let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.keyboardDoneTapped))
            keyboardToolbar.items = [cancelBarButton, flexBarButton, doneBarButton]
            self.textView.inputAccessoryView = keyboardToolbar
        }
    }
    var textViewPositionAdjusted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WKWebView && JS file
        let jsSourcePath = Bundle.main.path(forResource: "YouTubeClient", ofType: "js")
        let jsSourceContents = try! String(contentsOfFile: jsSourcePath!)
        let userScript = WKUserScript(source: jsSourceContents, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.add(self, name: "memotube")
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = .video
        } else {
            config.requiresUserActionForMediaPlayback = true
        }
        config.userContentController = userContentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        
        // Alert Controllers
        self.alertController = UIAlertController(title: "Oops", message: "You are not watching a video.", preferredStyle: .alert)
        self.saveAlertController = UIAlertController(title: "Add name", message: "", preferredStyle: UIAlertControllerStyle.alert)

        // TextView
        self.textView = UITextView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: 60)))
        self.view.insertSubview(self.textView, at: self.view.subviews.count - 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                print("You signed in!")
            } else {
                print("come")
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func move(direction: MovingDirection) {
        guard self.webView != nil else { return }
        if direction == .back && self.webView.canGoBack {
            self.webView.goBack()
        } else if direction == .forward && self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    func getSpeedRate(type: SpeedType) -> Double {
        switch type {
        case .slow:
            return 0.75
        case .normal:
            return 1.0
        case .fast:
            return 1.25
        case .veryFast:
            return 1.5
        case .superFast:
            return 2.0
        }
    }
    
    func addOptionsToMenu() {
        self.menuButton.addItem("memo", icon: UIImage(named: "pen"), handler: { item in
            if self.isVideoLoaded() {
                self.webView.evaluateJavaScript("pause()", completionHandler: { result, error in
                    guard error == nil else { return }
                    self.pausedTime = result as! Int
                    self.menuButton.close()
                    self.textView.isHidden = false
                    let time = Util.timeFormatted(totalSeconds: self.pausedTime)
                    self.textView.text = "\(self.webView.title ?? "") - \(time)\n\n"
                    self.textView.becomeFirstResponder()
                })
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        self.menuButton.addItem("rewind", icon: UIImage(named: "rewind"), handler: { item in
            if self.isVideoLoaded() {
                self.webView.evaluateJavaScript("rewind()", completionHandler: nil)
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        self.menuButton.addItem("speed", icon: UIImage(named: "speed1"), handler: { item in
            if self.isVideoLoaded() {
                if (self.speedType != .superFast) {
                    self.speedType = SpeedType(rawValue: self.speedType.rawValue + 1)!
                } else {
                    self.speedType = .slow
                }
                self.webView.evaluateJavaScript("changeSpeedRateTo(\(self.getSpeedRate(type: self.speedType)))", completionHandler: nil)
                item.iconImageView.image = UIImage(named: "speed" + String(self.speedType.rawValue))
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        self.menuButton.addItem("script", icon: UIImage(named: "script"), handler: { item in
            if self.isVideoLoaded() {
                if !self.loadingScript {
                   self.getAuthorization()
                }
                self.loadingScript = true
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        
    }
    
    var loadingScript = false
    
    func isVideoLoaded() -> Bool {
        return !self.webView.isLoading && ((self.webView.url!.absoluteString.range(of: "watch") != nil))
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if !textViewPositionAdjusted {
                let keyboardHeight = keyboardSize.height
                self.textView.frame = self.textView.frame.offsetBy(dx: 0, dy: self.view.frame.size.height - (keyboardHeight + self.textView.frame.size.height))
                textViewPositionAdjusted = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.menuButton.open()
        self.menuButton.close()
    }
    
    func keyboardCancalTapped() {
        self.view.endEditing(true)
        self.textView.isHidden = true
    }
    
    func keyboardDoneTapped() {
        self.view.endEditing(true)
        self.present(self.saveAlertController, animated: true, completion: { _ in
            self.textView.isHidden = true
        })
    }
}

extension YouTubeViewController: WKScriptMessageHandler, WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if ((webView.url?.absoluteString.range(of: "watch")) != nil) {
            self.webView.evaluateJavaScript("applyInlinePlay()", completionHandler: nil)
        }
        decisionHandler(.allow)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "memotube") {
            print("JavaScript is sending a message \(message.body)")
        }
    }

}

extension YouTubeViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // Here is where we add code after logging in
    }
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthViewController(authUI: authUI)
    }
}

extension YouTubeViewController: GIDSignInDelegate, GIDSignInUIDelegate {

    func getAuthorization() {
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/youtube.force-ssl"]
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            print(error.debugDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let accessToken = authentication.accessToken
//        let refreshToken = authentication.refreshToken
        
        DispatchQueue.global(qos: .userInitiated).async {
            YouTubeClient.shared.accessToken = accessToken!
            if let videoId = Util.getQueryStringParameter(url: self.webView.url?.absoluteString, param: "v") {
                YouTubeClient.shared.fetchCaptionId(videoId: videoId) { captionId in
                    if captionId != nil {
                        YouTubeClient.shared.fetchCaption(captionId: captionId!)
                    }
                }
            }
            //                let image = self.loadOrGenerateAnImage()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                // self.imageView.image = image
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

