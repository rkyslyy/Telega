//
//  FirstViewController.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController {

    // Outlets
    @IBOutlet weak var contactsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(contactsUpdated), name: CONTACTS_LOADED, object: nil)
    }
    
    @objc private func contactsUpdated() {
        print("RELOADING TABLE")
        self.contactsTable.reloadData()
    }
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.contacts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactCell
        let contact = DataService.instance.contacts![indexPath.row]
        let imageData = Data(base64Encoded: contact.avatar)
        let image = UIImage(data: imageData!)
        cell.avatarView.image = image
        cell.usernameLbl.text = contact.username
        cell.emailLbl.text = contact.email
        return cell
    }
}
