//
//  MeRoute.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire

extension TelegaAPI {
    class func getInfoAboutSelf(completion: @escaping () -> ()) {
        if DataService.instance.token != nil {
            DispatchQueue.global().async {
                Alamofire.request(ME_URL,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: AUTH_HEADER).responseJSON(completionHandler: { (response) in
                    guard let data = response.value as? [String : Any]
                        else { print("bad value"); return }
                    if let error = data["error"] {
                        return print(error)
                    }
                    let user = data["user"] as! [String : Any]
                    DataService.instance.id = (user["_id"] as! String)
                    DataService.instance.email = (user["email"] as! String)
                    DataService.instance.username = (user["username"] as! String)
                    DataService.instance.userAvatar = (user["avatar"] as! String)
                    DataService.instance.publicPem = (user["publicPem"] as! String)
                    let messages = user["messages"] as! [[String:Any]]
                    MessagesParser.buildMessages(messages: messages)
                    let contactsData = user["contacts"] as! [[String : Any]]
                    DataService.instance.contacts = contactsFrom(contactsData)
                    completion()
                })
            }
        }
    }
    
    class private func contactsFrom(_ contactsData: [[String:Any]]) -> [User] {
        return contactsData.compactMap({ (contact) -> User? in
            guard   let _id = contact["_id"] as? String,
                    let email = contact["email"] as? String,
                    let username = contact["username"] as? String,
                    let avatar = contact["avatar"] as? String,
                    let confirmed = contact["confirmed"] as? Bool,
                    let requestIsMine = contact["requestIsMine"] as? Bool,
                    let publicPem = contact["publicPem"] as? String,
                    let online = contact["online"] as? Bool,
                    let unread = contact["unread"] as? Bool
                    else { return nil }
            return User(id: _id,
                        email: email,
                        username: username,
                        avatar: avatar,
                        publicPem: publicPem,
                        confirmed: confirmed,
                        requestIsMine: requestIsMine,
                        online: online,
                        unread: unread)
        })
    }
}

class MessagesParser {
    
    class func buildMessages(messages: [[String:Any]]) {
        var structuredMessagesDict = [String:[(date: String, messages: [Message])]]()
        for message in messages {
            if (message["storeID"] as! String) == DataService.instance.id! {
                continue
            }
            let storeID = (message["storeID"] as! String)
            if structuredMessagesDict[storeID] == nil {
                structuredMessagesDict[storeID] = [(date: String, messages: [Message])]()
            }
        }
        for message in messages {
            let storeID = message["storeID"] as! String
            if structuredMessagesDict[storeID] == nil {
                continue
            }
            let date = (message["time"] as! String).components(separatedBy: "T")[0]
            if !does(date: date, existIn: structuredMessagesDict[storeID]!) {
                structuredMessagesDict[storeID]!.append((date: date, messages: [Message]()))
            }
        }
        for message in messages {
            let storeID = message["storeID"] as! String
            if structuredMessagesDict[storeID] == nil {
                continue
            }
            let date = (message["time"] as! String).components(separatedBy: "T")[0]
            for (index, tuple) in structuredMessagesDict[storeID]!.enumerated() {
                if tuple.date == date {
                    var text = message["message"] as! String
                    text = EncryptionService.decryptedMessage(text)
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "EET")
                    let time = dateFormatter.date(from:(message["time"] as! String).components(separatedBy: ".")[0] + "-0200")!
                    let messageToSave = Message(text: text, time: time, mine: message["mine"] as! Bool)
                    structuredMessagesDict[storeID]![index].messages.append(messageToSave)
                }
            }
        }
        DataService.instance.messages = structuredMessagesDict
    }
    
    class func does(date: String, existIn tuples: [(date: String, messages: [Message])]) -> Bool {
        for tuple in tuples {
            if tuple.date == date {
                return true
            }
        }
        return false
    }
}

