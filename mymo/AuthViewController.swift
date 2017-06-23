//
//  AuthViewController.swift
//  mymo
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
        
        let label = UILabel()
        let textView = UITextView()
        
        print(UIDevice.current.userInterfaceIdiom)
        if UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.model.hasPrefix("iPhone") {
            //iPhone
            label.frame = CGRect(x: 0, y: (self.view.bounds.size.height / 2) - 100, width: width, height: 50)
            textView.frame = CGRect(x: 0, y: (self.view.bounds.size.height / 2) - 50, width: width, height: 50)
        } else {
            //iPad
            // In order not to overlap signinView(Google, Facebook, Email thing),
            // I use view's height for figuring y, and 150 is the textView's height and extra margin.
            label.frame = CGRect(x: 0, y: (self.view.bounds.size.height / 2) - 200, width: width, height: 50)
            textView.frame = CGRect(x: 0, y: (self.view.bounds.size.height / 2) - 150, width: width, height: 50)
        }

        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "mymo"
        
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.textAlignment = .center
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.text = "Mark your favorite moments of YouTube"
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "background")
        imageViewBackground.contentMode = .scaleAspectFill
        
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        cover.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        imageViewBackground.addSubview(cover)
        
        self.view.insertSubview(imageViewBackground, at: 0)
        self.view.addSubview(label)
        self.view.addSubview(textView)
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
