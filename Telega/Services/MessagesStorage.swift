//
//  MessagesStorage.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/22/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

enum StoringResult {
	case freshContact
	case freshDate
	case freshMessage
}

enum MessagesParsingError: Error {
	case BadStoreID
	case BadContents
}

class MessagesStorage {

	// Variables
	static private var messages = [String: [DateMessages]]()
	static var numberOfMessages: Int {
		var count = 0
		messages.forEach { datesMessages in
			datesMessages.value.forEach({ (dateMessages) in
				count += dateMessages.messages.count
			})
		}
		return count
	}

	class func messagesExistWith(id: String) -> Bool {
		return messages[id] != nil
	}

	class func storeNew(
		message: Message,
		storeID: String,
		timeStr: String,
		completion: @escaping (StoringResult) -> ()
		) {
		let date = timeStr.components(separatedBy: "T")[0]
		if messages[storeID] != nil {
			if does(date: date, existIn: messages[storeID]!) {
				for dateMessages in messages[storeID]! where dateMessages.date == date {
					dateMessages.messages.insert(message, at: 0)
					completion(.freshMessage)
				}
			} else {
				messages[storeID]!.insert(DateMessages(date: date), at: 0)
				messages[storeID]![0].messages.append(message)
				completion(.freshDate)
			}
		} else {
			messages[storeID] = [DateMessages]()
			messages[storeID]!.append(DateMessages(date: date))
			messages[storeID]![0].messages.append(message)
			completion(.freshContact)
		}
	}

	class func messagesOfContactWith(
		id: String,
		andOfDateIndex index: Int
		) -> [Message]? {
		guard let datesMessages = messages[id] else { return nil }
		return datesMessages.indices.contains(index)
			? datesMessages[index].messages
			: nil
	}

	class func numberOfMessagesBy(dateIndex: Int, andContact id: String) -> Int {
		guard let datesMessages = messages[id] else { return 0 }
		return datesMessages.indices.contains(dateIndex)
			? datesMessages[dateIndex].messages.count
			: 0
	}

	class func numberOfDatesBy(user id: String) -> Int {
		return messages[id]?.count ?? 0
	}

	class func dateStringForIndex(_ index: Int, forID id: String) -> String? {
		return messages[id]?[index].date
	}

	class func buildMessagesFrom(_ messages: [[String:Any]]) {
		self.messages.removeAll()
		do {
			try getAllContactsFrom(messages)
			try getAllDatesFrom(messages)
			try getMessagesOfDatesFrom(messages)
		} catch {
			print("ERROR WHILE GETTING MESSAGES")
		}
	}

	class private func getAllContactsFrom(_ messages: [[String: Any]]) throws {
		for message in messages {
			guard let storeID = message["storeID"] as? String
			else { throw MessagesParsingError.BadStoreID }
			if storeID == DataService.instance.id! {
				continue
			}
			if self.messages[storeID] == nil {
				self.messages[storeID] = [DateMessages]()
			}
		}
	}

	class private func getAllDatesFrom(_ messages: [[String: Any]]) throws {
		for message in messages {
			guard let storeID = message["storeID"] as? String
			else { throw MessagesParsingError.BadStoreID }
			if self.messages[storeID] == nil {
				continue
			}
			guard var date = (message["time"] as? String)
			else { throw MessagesParsingError.BadContents }
			date = date.components(separatedBy: "T")[0]
			if !does(date: date, existIn: self.messages[storeID]!) {
				self.messages[storeID]!.insert(DateMessages(date: date), at: 0)
			}
		}
	}

	class private func getMessagesOfDatesFrom(_ messages: [[String: Any]]) throws {
		for message in messages {
			guard let storeID = message["storeID"] as? String
			else { throw MessagesParsingError.BadStoreID }
			if self.messages[storeID] == nil {
				continue
			}
			guard let longDate = (message["time"] as? String)
			else { throw MessagesParsingError.BadContents}
			let date = longDate.components(separatedBy: "T")[0]
			for dateMessages in self.messages[storeID]!
				where dateMessages.date == date {
					guard var text = message["message"] as? String,
						    let mine = message["mine"] as? Bool
					else { throw MessagesParsingError.BadContents}
					text = EncryptionService.decryptedMessage(text)
					let dateFormatter = ISO8601DateFormatter()
					dateFormatter.timeZone = TimeZone(abbreviation: "EET")
					let time = dateFormatter.date(
						from:longDate.components(
							separatedBy: ".")[0] + "-0200")!
					let messageToSave = Message(
						text: text,
						time: time,
						mine: mine)
					dateMessages.messages.insert(messageToSave, at: 0)
			}
		}
	}

	class func getLastMessageDateOf(id: String) -> Date? {
		guard let allDates = messages[id] else { return nil }
		let lastDate = allDates.first!
		return lastDate.messages.first!.time
	}

	class private func does(
		date: String,
		existIn tuples: [DateMessages]
		) -> Bool {
		for tuple in tuples where tuple.date == date {
			return true
		}
		return false
	}
}
