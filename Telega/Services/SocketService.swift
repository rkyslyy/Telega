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
        manager.defaultSocket.connect()
    }
    
    func emitReadMessagesFrom(id: String) {
        manager.defaultSocket.emit("messages_read", id, DataService.instance.id!)
    }
    
    func disconnect() {
        manager.defaultSocket.disconnect()
    }
    
    private func setupIntrocudeEvent() {
        manager.defaultSocket.on("introduce") { (responses, _) in
            if DataService.instance.token == nil {
                return
            }
            self.manager.defaultSocket.emit("introduce", DataService.instance.username!, DataService.instance.id!)
        }
    }
    
    private func setupUpdateContactsEvent() {
        manager.defaultSocket.on("update contacts") { (responses, _) in
            TelegaAPI.updateInfoAboutSelf {
                var body = [String:String]()
                if responses.count > 0 {
                    if let id = responses[0] as? String {
                        body["id"] = id
                        if responses.count > 1 {
                            body["delete"] = ""
                        }
                    }
                }
                NotificationCenter.default.post(name: CONTACTS_LOADED, object: nil, userInfo: body)
            }
        }
    }
    
    private func setupOnlineEvent() {
        manager.defaultSocket.on("online") { (responses, _) in
            let id = responses[0] as! String
            for (index, contact) in DataService.instance.contacts!.enumerated() {
                if contact.id == id {
                    DataService.instance.contacts![index].online = true
                }
            }
            NotificationCenter.default.post(name: UPDATE_CONTACT, object: nil, userInfo: ["id": id])
        }
    }
    
    private func setupOfflineEvent() {
        manager.defaultSocket.on("offline") { (responses, _) in
            let id = responses[0] as! String
            for (index, contact) in DataService.instance.contacts!.enumerated() {
                if contact.id == id {
                    DataService.instance.contacts![index].online = false
                }
            }
            NotificationCenter.default.post(name: UPDATE_CONTACT, object: nil, userInfo: ["id": id])
        }
    }
    
    private func setupMessagesReadEvent() {
        manager.defaultSocket.on("messages_read") { (responses, _) in
            let id = responses[0] as! String
            for (index, contact) in DataService.instance.contacts!.enumerated() {
                if contact.id == id  {
                    DataService.instance.contacts![index].unread = false
                }
            }
            NotificationCenter.default.post(name: UPDATE_CONTACT, object: nil, userInfo: ["id": id])
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
            let time = dateFormatter.date(from:(message["time"] as! String).components(separatedBy: ".")[0] + "-0200")!
            let mine = message["mine"] as! Bool
            let messageToSave = Message(text: text, time: time, mine: mine)
            let dateStr = (message["time"] as! String).components(separatedBy: "T")[0]
            if DataService.instance.messages[storeID] != nil {
                for (index, user) in DataService.instance.contacts!.enumerated() {
                    if user.id == storeID {
                        DataService.instance.contacts![index].unread = !mine
                    }
                }
                if MessagesParser.does(date: dateStr, existIn: DataService.instance.messages[storeID]!) {
                    for (index, tuple) in DataService.instance.messages[storeID]!.enumerated() {
                        if tuple.date == dateStr {
                            DataService.instance.messages[storeID]![index].messages.append(messageToSave)
                            NotificationCenter.default.post(name: MESSAGES_UPDATED, object: nil, userInfo: ["companionID":storeID])
                        }
                    }
                } else {
                    DataService.instance.messages[storeID]!.append((date: dateStr, messages: [Message]()))
                    DataService.instance.messages[storeID]![DataService.instance.messages[storeID]!.count - 1].messages.append(messageToSave)
                    NotificationCenter.default.post(name: MESSAGES_UPDATED, object: nil, userInfo: ["companionID":storeID,
                                                                                                    "newDate":true])
                }
            } else {
                DataService.instance.messages[storeID] = [(date: String, messages: [Message])]()
                for (index, user) in DataService.instance.contacts!.enumerated() {
                    if user.id == storeID {
                        DataService.instance.contacts![index].unread = !mine
                    }
                }
                DataService.instance.messages[storeID]!.append((date: dateStr, messages: [Message]()))
                DataService.instance.messages[storeID]![0].messages.append(messageToSave)
                NotificationCenter.default.post(name: MESSAGES_UPDATED, object: nil, userInfo: ["companionID":storeID,
                                                                                                "newDate":true])
            }
        }
    }
}
