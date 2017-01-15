//
//  WatchSessionManagerExt.swift
//  WG
//
//  Created by Nick Uzelac on 1/14/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionManagerExt: NSObject, WCSessionDelegate {
    
    // Instantiate the Singleton
    static let sharedManagerExt = WatchSessionManagerExt()
    private override init() {
        super.init()
        
    }
    
    //Reference is made for the session so it can be used to send / receive data
    private let session = WCSession.default()
    
    //Activate Session
    //Needs to be called to activate session before first use!
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watchOS - Session Activated")
    }
    
    func sendMessage(messageCode : Int) {
        session.sendMessage(["watchData" : messageCode], replyHandler: { (response) -> Void in
            print("watchOS - Sent Message")
        }, errorHandler: { (error) -> Void in
            print(error)
        })
    }
    
}
