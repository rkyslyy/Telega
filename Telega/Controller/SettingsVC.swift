//
//  SecondViewController.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var avatarView: CircleImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameTxtFld: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailLbl.text = DataService.instance.email
        usernameTxtFld.text = DataService.instance.username
        let data = Data(base64Encoded: DataService.instance.userAvatar!)
        let image = UIImage(data: data!)
        avatarView.image = image
    }
    
    @IBAction func changeAvatarPressed(_ sender: Any) {
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        view.endEditing(true)
        let imageData = avatarView.image!.pngData()
        let base64 = imageData?.base64EncodedString()
        TelegaAPI.instanse.editProfileWith(username: usernameTxtFld.text!, andAvatar: base64!)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        DataService.instance.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authVC = storyboard.instantiateViewController(withIdentifier: "authVC")
        present(authVC, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

