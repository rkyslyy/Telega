//
//  FirstViewController.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit
import SwiftyRSA

class ContactsVC: UIViewController {

	// Outlets
	@IBOutlet weak var contactsTable: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

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

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(contactsLoaded(notification:)),
			name: CONTACTS_LOADED,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didBecomeActive),
			name: UIApplication.didBecomeActiveNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateUser(notification:)),
			name: UPDATE_CONTACT,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(messagesUpdated(notification:)),
			name: MESSAGES_UPDATED,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(contactAdded),
			name: ADD_CONTACT,
			object: nil)
		NotificationCenter.default.addObserver(
			self, selector: #selector(contactDeleted(notification:)),
			name: DELETE_CONTACT,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(friendAccepted(notification:)),
			name: ACCEPT_FRIEND,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onlineChanged(notification:)),
			name: ONLINE_CHANGED,
			object: nil)
	}

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
		let contactsCount = DataService.instance.contacts!.count
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
		if let id = notification.userInfo?["id"] as? String {
			for (index, contact) in DataService.instance.contacts!.enumerated()
				where contact.id == id {
					contactsTable.reloadRows(
						at: [IndexPath(row: index, section: 0)],
						with: .none)
			}
		}
	}

	@objc private func updateUser(notification: Notification) {
		if let userinfo = notification.userInfo {
			if let index = userinfo["index"] as? Int {
				if contactsTable.visibleCells.isEmpty {
					contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
				} else {
					contactsTable.reloadRows(
						at: [IndexPath(row: index, section: 0)], with: .fade)
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

	override func viewWillAppear(_ animated: Bool) {
		contactsTable.reloadSections(IndexSet(integer: 0), with: .none)
	}

	@objc private func reloadContactsFromAPI() {
		TelegaAPI.getInfoAboutSelf {
			self.contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
			self.contactsTable.refreshControl?.endRefreshing()
		}
	}

	@objc private func contactsLoaded(notification: Notification) {
		if !DataService.instance.contacts!.isEmpty {
			contactsTable.reloadSections(IndexSet(integer: 0), with: .fade)
		}
	}
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {

	func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
		) {
		let contact = DataService.instance.contacts![indexPath.row]
		if contact.confirmed {
			performSegue(withIdentifier: "toDialogue",
									 sender: contact)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? DialogueVC {
			let contact = sender as! User
			dest.companion = contact
			do {
				dest.companionPublicKey = try PublicKey(pemEncoded: contact.publicPem)
			} catch {}
		}
	}

	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
		) -> Int {
		return DataService.instance.contacts?.count ?? 0
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
		) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "contactCell") as! ContactCell
		let contact = DataService.instance.contacts![indexPath.row]
		let imageData = Data(base64Encoded: contact.avatar)
		let image = UIImage(data: imageData!)
		cell.table = tableView
		cell.indexPath = indexPath
		cell.avatarView.image = image
		cell.usernameLbl.text = contact.username
		cell.emailLbl.text = contact.email
		cell.contactID = DataService.instance.contacts![indexPath.row].id
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
		let delete = UITableViewRowAction(
			style: .normal,
			title: "Delete") { action, index in
				TelegaAPI.deleteContactWith(
					id: DataService.instance.contacts![indexPath.row].id,
					completion: {})
			DataService.instance.contacts!.remove(at: indexPath.row)
			tableView.deleteRows(
				at: [indexPath],
				with: UITableView.RowAnimation.right)
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
