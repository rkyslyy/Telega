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
        contactsTable.refreshControl = UIRefreshControl()
        contactsTable.refreshControl?.addTarget(self, action: #selector(reloadContactsFromAPI), for: .valueChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contactsUpdated(notification:)), name: CONTACTS_LOADED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didBecomeActive() {
        contactsTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataService.instance.animatables.removeAll()
        contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    @objc private func reloadContactsFromAPI() {
        TelegaAPI.instanse.updateInfoAboutSelf {
            self.contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
            self.contactsTable.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func contactsUpdated(notification: Notification) {
        if let userinfo = notification.userInfo {
            if let id = userinfo["id"] as? String {
                var index = 0
                var found = false
                for cell in contactsTable.visibleCells as! [ContactCell] {
                    if cell.contactID == id {
                        found = true
                        break
                    }
                    index += 1
                }
                if found && userinfo["delete"] != nil {
                    contactsTable.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                } else if found && userinfo["delete"] == nil {
                    contactsTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            } else {
                contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        } else {
            contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
        }
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
        cell.table = tableView
        cell.indexPath = indexPath
        cell.avatarView.image = image
        cell.usernameLbl.text = contact.username
        cell.emailLbl.text = contact.email
        cell.contactID = DataService.instance.contacts![indexPath.row].id
        cell.setupStatus(confirmed: contact.confirmed, requestIsMine: contact.requestIsMine)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            TelegaAPI.instanse.deleteContactWith(id: DataService.instance.contacts![indexPath.row].id, completion: {
            })
            DataService.instance.contacts!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactCell
        cell.statusBtn.layer.removeAllAnimations()
    }
}