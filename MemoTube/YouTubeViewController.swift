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

enum SpeedType: Int {
    case slow, normal, fast, veryFast, superFast
}

enum MovingDirection {
    case back, forward
}

class YouTubeViewController: UIViewController, WKUIDelegate {

    var fromListView = false
    
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
            var urlString = "https://www.youtube.com/"
            if self.memo != nil {
                urlString += "watch?v=\(memo!.videoId)"
                if self.memo!.time != 0 {
                    urlString += "&t=\(Util.formatTime(totalSeconds: self.memo!.time, forParam: true))"
                }
            }
            let url = URL(string: urlString)
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
    
    var transcriptController: UIAlertController! {
        didSet {
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            }
            self.transcriptController.addAction(OKAction)
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
    
    // Script
    var transcriptView: UITextView! {
        didSet {
            self.transcriptView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.transcriptView.textColor = .white
            self.transcriptView.isHidden = true
            self.transcriptView.delegate = self
            self.transcriptView.isEditable = false
            self.transcriptView.isUserInteractionEnabled = true
            self.transcriptView.textColor = .white
        }
    }
    var transcriptDownloaded = false
    var loadingTranscript = false
    
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
        

        self.alertController = UIAlertController(title: "Oops", message: "You are not watching a video.", preferredStyle: .alert)
        self.transcriptController = UIAlertController(title: "Sorry", message: "The transcript is not available.", preferredStyle: .alert)


        self.textView = UITextView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: 60)))
        self.transcriptView = UITextView(frame: self.view.frame)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.transcriptViewTapped(sender:)))
        self.transcriptView.addGestureRecognizer(tgr)
        self.view.insertSubview(self.transcriptView, at: self.view.subviews.count - 1)
        self.view.insertSubview(self.textView, at: self.view.subviews.count - 1)
    }
    
    func transcriptViewTapped(sender: UITapGestureRecognizer) {
        self.transcriptView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                FirebaseClientHelper.shared.user = user
            } else {
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

    
    func addOptionsToMenu() {
        self.menuButton.addItem("memo", icon: UIImage(named: "pen"), handler: { item in
            if self.isVideoLoaded() {
                self.webView.evaluateJavaScript("pause()", completionHandler: { result, error in
                    guard error == nil else { return }
                    self.pausedTime = result as! Int
                    self.menuButton.close()
                    self.textView.isHidden = false
                    let time = Util.formatTime(totalSeconds: self.pausedTime, forParam: false)
                    if (self.fromListView) {
                        self.textView.text = self.memo!.content
                    } else {
                        self.textView.text = "\n\n\n\(self.webView.title ?? "") - \(time)"
                        self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
                    }
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
                self.webView.evaluateJavaScript("changeSpeedRateTo(\(Util.getSpeedRate(type: self.speedType)))", completionHandler: nil)
                item.iconImageView.image = UIImage(named: "speed" + String(self.speedType.rawValue))
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        self.menuButton.addItem("transcript", icon: UIImage(named: "transcript"), handler: { item in
            if self.isVideoLoaded() {
                if !self.loadingTranscript && !self.transcriptDownloaded {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let videoId = Util.getQueryStringParameter(url: self.webView.url?.absoluteString, param: "v") {
                            YouTubeClient.shared.fetchCaptionName(videoId: videoId) { name in
                                if name != nil {
                                    YouTubeClient.shared.fetchCaption(videoId: videoId, name: name!) { result in
                                        DispatchQueue.main.async {
                                            if result != nil {
                                                
                                                let transcript = NSMutableAttributedString(string: "")
                                                result!.forEach({text in
                                                    let sentence = text["text"]!.replacingOccurrences(of: "&#39;", with: "'")
                                                    let time = text["time"]!
                                                    let formattedTime = Util.formatTime(totalSeconds: Int(Float(time)!), forParam: false)
                                                    let string = "\(sentence) - \(formattedTime)"
                                                    
                                                    let attributes = [
                                                        NSFontAttributeName: UIFont.systemFont(ofSize: 18),
                                                        NSForegroundColorAttributeName: UIColor.white,
                                                    ]
                                                    
                                                    let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
                                                    attributedString.addAttribute(NSLinkAttributeName, value: time, range: NSMakeRange((sentence.characters.count + 3), formattedTime.characters.count))
                                                    attributedString.append(NSMutableAttributedString(string:"\n"))
                                                    transcript.append(attributedString)
                                                })
                                                self.transcriptView.attributedText = transcript
                                                self.transcriptView.linkTextAttributes = [
                                                    NSForegroundColorAttributeName: UIColor.blue,
                                                ]
                                                self.transcriptView.isHidden = false
                                                self.transcriptDownloaded = true
                                            } else {
                                                self.present(self.transcriptController, animated: true, completion: nil)
                                            }
                                            self.loadingTranscript = false
                                        }
                                    }
                                } else {
                                    self.present(self.transcriptController, animated: true, completion: nil)
                                    self.loadingTranscript = false
                                }
                            }
                        }
                    }
                } else if self.transcriptDownloaded {
                    self.transcriptView.isHidden = false
                } else {
                    print("something unexpected happened")
                }
                self.loadingTranscript = true
                self.menuButton.close()
            } else {
                self.present(self.alertController, animated: true, completion: nil)
            }
        })
        
    }
    
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
        let timestamp = ServerValue.timestamp()
        let content = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.fromListView {
            FirebaseClientHelper.shared.update(data: content, path: "\(FirebaseClientHelper.shared.getPath(object: "memo")!)/\(self.memo!.key!)/content")
            FirebaseClientHelper.shared.update(data: timestamp, path: "\(FirebaseClientHelper.shared.getPath(object: "memo")!)/\(self.memo!.key!)/updatedTime")
        } else {
            let memo = [
                "videoId": Util.getQueryStringParameter(url: self.webView.url?.absoluteString, param: "v") ?? "",
                "time": self.pausedTime,
                "title": self.webView.title ?? "",
                "content": content,
                "addedTime": timestamp,
                "updatedTime": timestamp,
            ] as [String : Any]
            FirebaseClientHelper.shared.push(data: memo, path: FirebaseClientHelper.shared.getPath(object: "memo")!)
        }
        self.textView.text = ""
        self.textView.isHidden = true
    }
}

extension YouTubeViewController: WKScriptMessageHandler, WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if ((webView.url?.absoluteString.range(of: "watch")) != nil) {
            if self.memo != nil && self.memo!.videoId == Util.getQueryStringParameter(url: self.webView.url?.absoluteString, param: "v") {
                self.fromListView = true
            } else {
                self.fromListView = false
            }
            self.transcriptDownloaded = false
            self.transcriptView.text = ""
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

extension YouTubeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.transcriptView.isHidden = true
        self.webView.evaluateJavaScript("seekTo(\(URL.absoluteString))", completionHandler: nil)
        return false
    }

}
