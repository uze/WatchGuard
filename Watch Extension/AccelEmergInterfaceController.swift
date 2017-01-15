//
//  AccelEmergInterfaceController.swift
//  WG
//
//  Created by Nick Uzelac on 1/14/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class AccelEmergInterfaceController: WKInterfaceController {
    
    @IBOutlet var backgroundGroup: WKInterfaceGroup!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBAction func helpButton() {
        timer?.invalidate()
        backgroundGroup.setBackgroundColor(UIColor.green)
        presentController(withName: "EmergInfoController", context: 0)
    }
    
    var timeLeft: Int = 15
    var timer: Timer?
    
    func update() {
        if(timeLeft > 0) {
            WKInterfaceDevice.current().play(.notification)
            timeLeft -= 1
            timerLabel.setText(String(timeLeft) + " sec")
        } else {
            helpButton()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        timerLabel.setText(String(timeLeft) + " sec")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        timer?.invalidate()
    }
    
}

