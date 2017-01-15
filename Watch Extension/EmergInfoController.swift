//
//  EmergInfoController.swift
//  WG
//
//  Created by Nick Uzelac on 1/14/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class EmergInfoInterfaceController: WKInterfaceController {
    
    
    override func awake(withContext context: Any?) {
        WatchSessionManagerExt.sharedManagerExt.sendMessage(messageCode: context as! Int)
    }
    
    override func willActivate() {
        
        //WatchSessionManagerExt.sharedManagerExt.sendMessage(messageCode: 0)
    }
    
}

