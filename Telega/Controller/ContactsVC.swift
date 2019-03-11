//
//  FirstViewController.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import Gifu
import SwiftyRSA
import SwiftEntryKit

class ContactsVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var contactsTable: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  // Variables
  var loadingRipple: GIFImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservers()
    if DataService.instance.contacts == nil {
      searchBar.delegate = self
      navigationItem.title = "Updating..."
      loadingRipple = GIFImageView(
        frame: CGRect(
          x: view.frame.width / 2 - 75,
          y: view.frame.height / 2 - 75,
          width: 150,
          height: 150))
      loadingRipple?.animate(withGIFNamed: "ripple")
      view.addSubview(loadingRipple!)
    }
    
    contactsTable.delegate = self
    contactsTable.dataSource = self
    contactsTable.refreshControl = UIRefreshControl()
    contactsTable.refreshControl?.addTarget(
      self,
      action: #selector(reloadContactsFromAPI),
      for: .valueChanged)
    
    let tap = UITapGestureRecognizer(
      target: self,
      action: #selector(hideKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    contactsTable.reloadSections(IndexSet(integer: 0), with: .none)
  }
  
  
  // Selector methods
  @objc private func onlineChanged(notification: Notification) {
    guard let userinfo = notification.userInfo,
      let index = userinfo["index"] as? Int
      else { return }
    contactsTable.reloadRows(
      at: [IndexPath(row: index, section: 0)],
      with: .none)
  }
  
  @objc private func contactDeleted(notification: Notification) {
    guard let userinfo = notification.userInfo,
      let index = userinfo["index"] as? Int
      else { return }
    contactsTable.deleteRows(
      at: [IndexPath(row: index, section: 0)],
      with: .fade)
  }
  
  @objc private func contactAdded() {
    DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!).forEach({print($0.email)})
    let contactsCount = DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!).count
    if contactsCount > 1 {
      return contactsTable.insertRows(
        at: [IndexPath(row: contactsCount - 1, section: 0)],
        with: .top)
    }
    contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
  }
  
  @objc private func friendAccepted(notification: Notification) {
    guard let userinfo = notification.userInfo,
      let index = userinfo["index"] as? Int
      else { return }
    contactsTable.reloadRows(
      at: [IndexPath(row: index, section: 0)],
      with: .fade)
  }
  
  @objc private func messagesUpdated(notification: Notification) {
    contactsTable.reloadData()
  }
  
  @objc func openDialogue() {
    print("OPENING DIALOGUE")
  }
  
  @objc private func updateUser(notification: Notification) {
    if let userinfo = notification.userInfo {
      if let index = userinfo["index"] as? Int {
        if contactsTable.visibleCells.isEmpty {
          contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
        } else {
          contactsTable.reloadRows(
            at: [IndexPath(row: index, section: 0)], with: .none)
        }
      }
    } else {
      contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
    }
  }
  
  @objc private func hideKeyboard() {
    view.endEditing(true)
  }
  
  @objc private func didBecomeActive() {
    contactsTable.reloadData()
  }
  
  @objc private func reloadContactsFromAPI() {
    TelegaAPI.getInfoAboutSelf {
      self.contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
      self.contactsTable.refreshControl?.endRefreshing()
    }
  }
  
  @objc private func contactsLoaded(notification: Notification) {
    navigationItem.title = "Contacts"
    loadingRipple?.removeFromSuperview()
    loadingRipple = nil
    if !DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!).isEmpty {
      contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
    }
  }
  
  @objc private func settingsChanged(notification: Notification) {
    if let userinfo = notification.userInfo {
      if let index = userinfo["index"] as? Int {
        contactsTable.reloadRows(
          at: [IndexPath(row: index, section: 0)], with: .fade)
      }
    }
  }
  
  private func setupObservers() {
    setupObserverFor(event: JUST_RELOAD, selector: #selector(justReload))
    setupObserverFor(event: ADD_CONTACT, selector: #selector(contactAdded))
    setupObserverFor(
      event: CONTACTS_LOADED,
      selector: #selector(contactsLoaded(notification:)))
    setupObserverFor(
      event: UIApplication.didBecomeActiveNotification,
      selector: #selector(didBecomeActive))
    setupObserverFor(
      event: UPDATE_CONTACT,
      selector: #selector(updateUser(notification:)))
    setupObserverFor(
      event: MESSAGES_UPDATED,
      selector: #selector(messagesUpdated(notification:)))
    setupObserverFor(
      event: DELETE_CONTACT,
      selector: #selector(contactDeleted(notification:)))
    setupObserverFor(
      event: ACCEPT_FRIEND,
      selector: #selector(friendAccepted(notification:)))
    setupObserverFor(
      event: ONLINE_CHANGED,
      selector: #selector(onlineChanged(notification:)))
    setupObserverFor(
      event: SETTINGS_CHANGED,
      selector: #selector(settingsChanged(notification:)))
    setupObserverFor(
      event: MESSAGES_UPDATED,
      selector: #selector(showEntry(notification:)))
  }
  
  private func setupObserverFor(event: Notification.Name, selector: Selector) {
    NotificationCenter.default.addObserver(
      self,
      selector: selector,
      name: event,
      object: nil)
  }
  
  @objc private func justReload() {
    contactsTable.reloadData()
  }
  
  @objc func showEntry(notification: Notification) {
    
    guard let userinfo = notification.userInfo,
          let id = userinfo["id"] as? String,
          let text = userinfo["text"] as? String,
          let mine = userinfo["mine"] as? Bool,
          !mine,
          !(navigationController?.visibleViewController is AuthVC)
    else { return }
    if let dVC = navigationController?.visibleViewController as? DialogueVC,
      dVC.companion.id == id {
      return
    }
    for contact in DataService.instance.contacts! where contact.id == id {
      SwiftEntryKit.displayNew(
        message: text,
        from: contact.username,
        contact: contact,
        viewController: self)
    }
  }
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
    ) {
    let contact = DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!)[indexPath.row]
    if contact.confirmed {
      SwiftEntryKit.dismiss()
      performSegue(withIdentifier: "toDialogue",
                   sender: contact)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? DialogueVC {
      let contact = sender as! User
      dest.companion = contact
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
    ) -> Int {
    return DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!).count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "contactCell") as! ContactCell
    let contact = DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!)[indexPath.row]
    let imageData = Data(base64Encoded: contact.avatar)
    let image = UIImage(data: imageData!)
    cell.table = tableView
    cell.indexPath = indexPath
    cell.avatarView.image = image
    cell.avatarView.backgroundColor = .darkGray
    cell.usernameLbl.text = contact.username
    cell.emailLbl.text = contact.email
    cell.contactID = DataService.instance.contactsFilteredWith(
      keyword: searchBar.text!)[indexPath.row].id
    cell.setupStatus(
      confirmed: contact.confirmed,
      requestIsMine: contact.requestIsMine,
      online: contact.online,
      unread: contact.unread)
    return cell
  }
  
  func tableView(
    _ tableView: UITableView,
    editActionsForRowAt indexPath: IndexPath
    ) -> [UITableViewRowAction]? {
    let deletionBlock = {
      TelegaAPI.deleteContactWith(
        id: DataService.instance.contactsFilteredWith(
          keyword: self.searchBar.text!)[indexPath.row].id,
        completion: {})
      DataService.instance.deleteContactWith(
        id: DataService.instance.contactsFilteredWith(
          keyword: self.searchBar.text!)[indexPath.row].id)
      tableView.deleteRows(
        at: [indexPath],
        with: UITableView.RowAnimation.right)
    }
    let delete = UITableViewRowAction(
      style: .normal,
      title: "Delete") { action, index in
        if DataService.instance.contactsFilteredWith(
          keyword: self.searchBar.text!)[indexPath.row].confirmed {
          let alert = UIAlertController(
            title: "Warning",
            message: "If you delete this contact " +
            "your whole conversation will also be deleted",
            preferredStyle: .alert)
          let ok = UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { (_) in
              deletionBlock()
          })
          let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alert.addAction(ok)
          alert.addAction(no)
          self.present(alert, animated: true, completion: nil)
        } else {
          deletionBlock()
        }
    }
    delete.backgroundColor = .red
    return [delete]
  }
  
  func tableView(
    _ tableView: UITableView,
    didEndDisplaying cell: UITableViewCell,
    forRowAt indexPath: IndexPath
    ) {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "contactCell") as! ContactCell
    cell.statusBtn.layer.removeAllAnimations()
  }
}

extension ContactsVC: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    contactsTable.reloadData()
  }
}
