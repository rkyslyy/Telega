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
    @IBOutlet weak var alreadyInListLbl: UILabel!
    
    // Variables
    var emails = [String]()
    var fetchedUser : User?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        saveBtn.isEnabled = false
        let tap =  UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        print(fetchedUser!.id)
        TelegaAPI.instanse.addContactWith(id: fetchedUser!.id) {
            DataService.instance.contacts!.append(self.fetchedUser!)
            self.navigationController?.popViewController(animated: true)
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
        alreadyInListLbl.isHidden = !userAlreadyInList()
        avatarView.layer.cornerRadius = avatarView.frame.width / 2
    }
    
    private func userAlreadyInList() -> Bool {
        for contact in DataService.instance.contacts! {
            if contact.email == fetchedUser!.email {
                saveBtn.isEnabled = false
                return true
            }
        }
        return false
    }
    
    private func showNoResults() {
        avatarView.isHidden = true
        usernameLbl.isHidden = true
        noResultsLbl.isHidden = false
        noResultsLbl.text = "No user with such email found"
    }
}
