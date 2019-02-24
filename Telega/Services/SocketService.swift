//
//  SocketService.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/19/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation
import SocketIO

class SocketService {

	static let instance = SocketService()

	var manager = SocketManager(socketURL: URL(string: BASE_URL)!)

	func establishConnection() {
		manager = SocketManager(socketURL: URL(string: BASE_URL)!)
		setupIntrocudeEvent()
		setupUpdateContactsEvent()
		setupOnlineEvent()
		setupOfflineEvent()
		setupMessagesReadEvent()
		setupUpdateMessagesEvent()
		setupAddContactEvent()
		setupAcceptFriendEvent()
		setupDeleteContactEvent()
		manager.defaultSocket.connect()
	}

	func emitReadMessagesFrom(id: String) {
		manager.defaultSocket.emit(
			"messages_read",
			id,
			DataService.instance.id!)
	}

	func disconnect() {
		manager.defaultSocket.disconnect()
	}

	private func setupIntrocudeEvent() {
		manager.defaultSocket.on("introduce") { (responses, _) in
			if DataService.instance.token == nil {
				return
			}
			self.manager.defaultSocket.emit(
				"introduce",
				DataService.instance.username!,
				DataService.instance.id!)
		}
	}

	private func setupAddContactEvent() {
		manager.defaultSocket.on("add_contact") { (_, _) in
			TelegaAPI.getInfoAboutSelf {
				NotificationCenter.default.post(
					name: ADD_CONTACT,
					object: nil,
					userInfo: nil)
			}
		}
	}

	private func setupAcceptFriendEvent() {
		manager.defaultSocket.on("accept_friend") { (responses, _) in
			if responses.isEmpty {
				return
			}
			guard let id = responses[0] as? String else { return }
			for (index, contact) in DataService.instance.contacts!.enumerated()
				where contact.id == id {
					print(contact.online)
					contact.confirmed = true
					NotificationCenter.default.post(
						name: ACCEPT_FRIEND,
						object: nil,
						userInfo: ["index": index])
			}
		}
	}

	private func setupDeleteContactEvent() {
		manager.defaultSocket.on("delete_contact") { (responses, _) in
			if responses.isEmpty {
				return
			}
			guard let id = responses[0] as? String else { return }
			for (index, contact) in DataService.instance.contacts!.enumerated()
				where contact.id == id {
					DataService.instance.contacts!.remove(at: index)
					NotificationCenter.default.post(
						name: DELETE_CONTACT,
						object: nil,
						userInfo: ["index": index])
			}
		}
	}

	private func setupUpdateContactsEvent() {
//		manager.defaultSocket.on("update contacts") { (responses, _) in
//			TelegaAPI.getInfoAboutSelf {
//				if responses.isEmpty {
//					return
//				}
//				var body = [String:Any]()
//				if let id = responses[0] as? String,
//					DataService.instance.contacts!.count != 0 {
//					for (index, contact) in DataService.instance.contacts!.enumerated() {
//							body["index"] = index
//							if responses.count > 1 {
//								body["delete"] = ""
//							}
//							NotificationCenter.default.post(
//								name: UPDATE_CONTACT,
//								object: nil,
//								userInfo: body)
//					}
//				} else {
//					NotificationCenter.default.post(
//						name: UPDATE_CONTACT,
//						object: nil,
//						userInfo: nil)
//				}
//			}
//		}
	}

	private func setupOnlineEvent() {
		manager.defaultSocket.on("online_changed") { (responses, _) in
			if responses.count < 2 {
				return
			}
			guard let id = responses[0] as? String,
					  let online = responses[1] as? Bool
			else { return }
			for (index, contact) in DataService.instance.contacts!.enumerated()
				where contact.id == id {
					contact.online = online
					NotificationCenter.default.post(
						name: ONLINE_CHANGED,
						object: nil,
						userInfo: ["id": id,
											 "index": index])
			}
		}
	}

	private func setupOfflineEvent() {
		manager.defaultSocket.on("offline") { (responses, _) in
			if responses.isEmpty {return}
			guard let id = responses[0] as? String else { return }
			for (index, contact) in
				DataService.instance.contacts!.enumerated() {
					if contact.id == id {
						DataService.instance.contacts![index].online = false
					}
			}
			NotificationCenter.default.post(
				name: UPDATE_CONTACT,
				object: nil,
				userInfo: ["id": id])
		}
	}

	private func setupMessagesReadEvent() {
		manager.defaultSocket.on("messages_read") { (responses, _) in
			if responses.isEmpty {return}
			guard let id = responses[0] as? String else { return }
			for (index, contact) in
				DataService.instance.contacts!.enumerated() {
					if contact.id == id  {
						DataService.instance.contacts![index].unread = false
					}
			}
			NotificationCenter.default.post(
				name: UPDATE_CONTACT,
				object: nil,
				userInfo: ["id": id])
		}
	}

	private func setupUpdateMessagesEvent() {
		manager.defaultSocket.on("update messages") { (responses, _) in
			let message = responses[0] as! [String:Any]
			let storeID = message["storeID"] as! String
			var text = message["message"] as! String
			text = EncryptionService.decryptedMessage(text)
			let dateFormatter = ISO8601DateFormatter()
			dateFormatter.timeZone = TimeZone(abbreviation: "EET")
			let time = dateFormatter.date(
				from:(message["time"] as! String).components(
					separatedBy: ".")[0] + "-0200")!
			let mine = message["mine"] as! Bool
			let messageToSave = Message(text: text, time: time, mine: mine)
			MessagesStorage.storeNew(
				message: messageToSave,
				storeID: storeID,
				timeStr: (message["time"] as! String),
				completion: { (result) in
					for contact in DataService.instance.contacts!
						where contact.id == storeID {
							contact.unread = !mine
					}
					NotificationCenter.default.post(
						name: MESSAGES_UPDATED,
						object: nil,
						userInfo: ["storing_result": result,
											 "id": storeID])
			})
		}
	}
}
