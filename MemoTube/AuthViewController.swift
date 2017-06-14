//
//  AuthViewController.swift
//  MemoTube
//
//  Created by ShimmenNobuyoshi on 2017/06/07.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class AuthViewController: FUIAuthPickerViewController {
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let label = UILabel(frame: CGRect(x: 0, y: 180, width: width, height: 30))
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "MemoTube"
        
        let textView = UITextView(frame: CGRect(x: 5, y: 250, width: width - 5, height: 100))
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.textAlignment = .center
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.text = "Start saving your favorite moments of YouTube"
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "background")
        imageViewBackground.contentMode = .scaleAspectFill
        
        self.view.insertSubview(imageViewBackground, at: 0)
        self.view.addSubview(label)
        self.view.addSubview(textView)
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
