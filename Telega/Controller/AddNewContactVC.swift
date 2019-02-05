//
//  AddNewContactVC.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/31/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class AddNewContactVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var avatarView: CircleImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var noResultsLbl: UILabel!
    
    // Variables
    var emails = [String]()
    var fetchedUser : User?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        saveBtn.isEnabled = false
        let tap =  UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        TelegaAPI.instanse.addContactWith(id: fetchedUser!.id) {
            
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension AddNewContactVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        guard let query = searchBar.text, searchBar.text! != "" else { return }
        TelegaAPI.instanse.getUserFor(email: query.lowercased()) { (user) in
            if user != nil {
                if user?.email == DataService.instance.email! {
                    self.showNoResults()
                    self.noResultsLbl.text = "You were looking for yourself"
                    return self.saveBtn.isEnabled = false
                }
                self.saveBtn.isEnabled = true
                self.fetchedUser = user
                return self.showFetchedUser()
            }
            self.saveBtn.isEnabled = false
            self.showNoResults()
        }
    }
    
    private func showFetchedUser() {
        let imageData = Data(base64Encoded: fetchedUser!.avatar)
        let image = UIImage(data: imageData!)
        avatarView.image = image
        usernameLbl.text = fetchedUser!.username
        avatarView.isHidden = false
        usernameLbl.isHidden = false
        noResultsLbl.isHidden = true
    }
    
    private func showNoResults() {
        avatarView.isHidden = true
        usernameLbl.isHidden = true
        noResultsLbl.isHidden = false
        noResultsLbl.text = "No user with such email found"
    }
}
