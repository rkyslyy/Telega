//
//  DialogueVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/7/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class DialogueVC: UIViewController {
    
    
    
    var dialogueTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = dialogueTitle
    }
}
