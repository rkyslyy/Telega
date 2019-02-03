//
//  AddNewContactVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class AddNewContactVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var avatarView: CircleImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        saveBtn.isEnabled = false
    }
    
    
    @IBAction func addContactPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
