//
//  AddNewContactVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class AddNewContactVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func addContactPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
