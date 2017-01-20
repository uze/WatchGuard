//
//  ViewController.swift
//  WG
//
//  Created by Nick Uzelac on 1/14/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var sessionStatusLabel: UILabel!
    
    var session: WCSession!
    var emergCode: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = WCSession.default()
        session.delegate = self
        session.activate()
        
        sendMessage()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS - Session Activated")
        sessionStatusLabel.text = "Watch is connected."
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject],replyHandler: ([String : AnyObject]) -> Void) {
        print("message received")
        emergCode = message["watchData"] as! Int
        switch emergCode {
        case 0:
            traumaResponse()
            break
        case 1:
            extremeHeartRateResponse()
            break
        default:
            print("Unexpected emergency code")
        }
    }
    
    func sendMessage() {
        session.sendMessage(["userData" : [User.name, User.bloodType]], replyHandler: { (response) -> Void in
            print("watchOS - Sent Message")
        }, errorHandler: { (error) -> Void in
            print(error)
        })
    }
    
    func traumaResponse() {
        sessionStatusLabel.text = "Sudden Trauma! Help needed."
        performSegue(withIdentifier: "sendMsg", sender: nil)
        
    }
    
    func extremeHeartRateResponse() {
        sessionStatusLabel.text = "Extreme Heart Rate! Help needed."
        performSegue(withIdentifier: "recordVideo", sender: nil)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS - Watch Session Deactivated")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS - Watch Session has become Inactive")
    }
}


