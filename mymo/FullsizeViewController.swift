//
//  FullsizeViewController.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/08/13.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RealmSwift

class FullsizeViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView! {
        didSet {
            self.webView.delegate = self
            self.webView.allowsInlineMediaPlayback = true
            self.webView.mediaPlaybackRequiresUserAction = false
        }
    }
    var videoId: String = ""
    var videoTitle: String = ""
    var startingTime: Int = 0
    
    var alertController: UIAlertController! {
        didSet {
            let OKAction = UIAlertAction(title: "OK", style: .default) { [unowned self] action in
                self.dismiss(animated: true, completion: nil)
                if self.alertController.message != "You are not watching anything." {
                    self.alertController.message = "You are not watching anything."
                }
            }
            self.alertController.addAction(OKAction)
        }
    }
    
    // Transcript
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
    
    func transcriptViewTapped(sender: UITapGestureRecognizer) {
        self.transcriptView.isHidden = true
    }
    
    var transcriptController: UIAlertController! {
        didSet {
            let OKAction = UIAlertAction(title: "OK", style: .default) { [unowned self] action in
                self.transcriptController.dismiss(animated: true, completion: nil)
            }
            self.transcriptController.addAction(OKAction)
        }
    }
    
    // Moment
    var pausedTime = 0
    var moment: Moment? {
        didSet {
            if self.moment != nil {
                self.videoId = moment!.videoId
                self.startingTime = moment!.time
            }
        }
    }
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
    
    var transcriptDownloaded = false
    var loadingTranscript = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Change User Agent so that you can change the playbackrate of a video
        UserDefaults.standard.register(defaults: ["UserAgent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.45 Safari/535.19"])
        
        // Enable the app to play an audio on the background.
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayAndRecord,
                with: .defaultToSpeaker)
        } catch {
            print("Failed to set audio session category.  Error: \(error)")
        }
        self.alertController = UIAlertController(title: "Oops", message: "You are not watching anything.", preferredStyle: .alert)
        self.transcriptController = UIAlertController(title: "Sorry", message: "The transcript is not available.", preferredStyle: .alert)
        
        
        self.textView = UITextView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: 80)))
        self.transcriptView = UITextView(frame: self.view.frame)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.transcriptViewTapped(sender:)))
        self.transcriptView.addGestureRecognizer(tgr)
        self.view.addSubview(self.transcriptView)
        self.view.addSubview(self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadHTMLString(self.getSource(fileName: "FullScreen", type: "html").replacingFirstOccurrenceOfString(target: "iframeSrc", with: "https://www.youtube.com/embed/\(videoId)?start=\(self.startingTime)&controls=1&showinfo=0&autoplay=1&playsinline=1&enablejsapi=1&fs=0&rel=0&modestbranding=1"), baseURL: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        self.transcriptDownloaded = false
        self.transcriptView.text = ""
        self.moment = nil
        self.videoId = ""
        self.videoTitle = ""
        self.startingTime = 0
    }
    
    func getSource(fileName: String, type: String) -> String {
        let sourcePath = Bundle.main.path(forResource: fileName, ofType: type)
        let content = try! String(contentsOfFile: sourcePath!).trimmingCharacters(in: .whitespacesAndNewlines)
        return content
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.textView.frame = self.textView.frame.offsetBy(dx: 0, dy: self.view.frame.size.height - (keyboardHeight + self.textView.frame.size.height))
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.textView.frame = CGRect(origin: CGPoint.zero, size: self.textView.frame.size)
        self.webView.frame = CGRect(origin: CGPoint.zero, size: self.webView.frame.size)
    }
    
    func keyboardCancalTapped() {
        self.view.endEditing(true)
        self.textView.isHidden = true
    }
    
    func keyboardDoneTapped() {
        self.view.endEditing(true)
        let content = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let timeStamp = NSDate().timeIntervalSince1970
        let realm = try! Realm()
        if self.moment != nil {
            try! realm.write {
                self.moment!.content = content
                self.moment!.updatedTime = timeStamp
            }
        } else {
            let data = [
                "videoId": self.videoId,
                "time": self.pausedTime,
                "title": self.videoTitle,
                "content": content,
                "addedTime": timeStamp
                ] as [String : Any]
            let moment = Moment(value: data)
            try! realm.write {
                realm.add(moment)
            }
        }
        self.textView.text = ""
        self.textView.isHidden = true
    }

}

extension FullsizeViewController: UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.scheme == "mymo" {
            let message = request.url!.host!
            print(message)
            switch message {
            case "close":
                self.dismiss(animated: true, completion: nil)
            case "mark":
                self.mark(time: Int(Util.getQueryStringParameter(url: request.url!.absoluteString, param: "time")!)!)
            case "transcript":
                self.getTranscript()
            default:
                break
            }
            return false
        }
        return true
    }
    
    func mark(time: Int) {
        if self.moment != nil {
            self.textView.text = self.moment!.content
        } else {
            self.pausedTime = time
            let formattedTime = Util.formatTime(totalSeconds: time, forParam: false)
            self.textView.text = "\n\n\(self.videoTitle) - \(formattedTime)"
            self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
        }
        self.textView.isHidden = false
        self.textView.becomeFirstResponder()
    }
    
    func getTranscript() {
        if !self.loadingTranscript && !self.transcriptDownloaded {
            DispatchQueue.global(qos: .userInitiated).async {
                YouTubeClient.shared.fetchCaptionName(videoId: self.videoId) { name in
                    if name != nil {
                        YouTubeClient.shared.fetchCaption(videoId: self.videoId, name: name!) { result in
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
        } else if self.transcriptDownloaded {
            self.transcriptView.isHidden = false
        } else {
            print("something unexpected happened")
        }
        self.loadingTranscript = true
    }
}

extension FullsizeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.transcriptView.isHidden = true
        self.webView.stringByEvaluatingJavaScript(from: "seekTo('\(URL.absoluteString)')")
        return false
    }
    
}


extension String {
    
    func replacingFirstOccurrenceOfString(target: String, with replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self.replacingOccurrences(of: target, with: replaceString)
    }

}
