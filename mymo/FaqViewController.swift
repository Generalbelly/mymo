//
//  FAQViewController.swift
//  mymo
//
//  Created by ShimmenNobuyoshi on 2017/08/19.
//  Copyright © 2017年 ShimmenNobuyoshi. All rights reserved.
//

import Eureka

class FaqViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FAQ"
        form +++ Section(header: "How can I play videos without having the app open?", footer: "")
            <<< TextAreaRow() { row in
                row.cell.height = { 160 }
                row.disabled = true
                row.value = "To have a video play in the background, open the video in fullscreen mode, then press the home button to close the app. The video will stop temporarily at this time. Swipe up Control Center on your home screen, and press play to hear the video's audio."
        }
    }
}
