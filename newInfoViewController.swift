//
//  newInfoViewController.swift
//  WG
//
//  Created by Nick Uzelac on 1/15/17.
//  Copyright © 2017 Simplex HackAZ. All rights reserved.
//

import Foundation
import UIKit

class newInfoViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bloodTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    
    @IBAction func saveInfo(_ sender: Any)
    {
        User.name = nameTextField.text!
        User.bloodType = bloodTextField.text!
        User.emergContact = contactTextField.text!
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        nameTextField.text = User.name
        bloodTextField.text = User.bloodType
        contactTextField.text = User.emergContact
    }
    
}
