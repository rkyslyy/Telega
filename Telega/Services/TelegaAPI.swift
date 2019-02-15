//
//  File.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation
import BCryptSwift
import Alamofire
import SwiftyRSA
import SocketIO

class TelegaAPI {
    static let instanse = TelegaAPI()
    
    var manager = SocketManager(socketURL: URL(string: BASE_URL)!)
    
    func changePasswordTo(_ password: String, withPem pem: String, completion: @escaping () -> ()) {
        let header = [
            "x-auth-token": DataService.instance.token!
        ]
        let body = [
            "password": password,
            "pem": pem
        ]
        Alamofire.request(CHANGE_PASSWORD_URL, method: .put, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            completion()
        }
    }
    
    func send(message: String,
              toUserWithID id: String,
              andStoreCopyForMe messageForMe: String,
              completion: @escaping (String) -> ()) {
        let header = [
            "x-auth-token": DataService.instance.token!
        ]
        let body = [
            "messageForMe": messageForMe,
            "messageForThem": message,
            "theirID": id
        ]
        Alamofire.request(MESSAGES_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            guard let data = response.value as? [String : Any] else { print("bad value"); completion(":("); return }
            let time = data["time"] as! String
            print(response)
            completion(time)
        }
    }
    
    func establishConnection() {
        manager = SocketManager(socketURL: URL(string: BASE_URL)!)
        manager.defaultSocket.on("introduce") { (responses, _) in
            if DataService.instance.token == nil {
                return  
            }
            self.manager.defaultSocket.emit("introduce", DataService.instance.username!, DataService.instance.id!)
        }
        manager.defaultSocket.on("update contacts") { (responses, _) in
            self.updateInfoAboutSelf {
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
        manager.defaultSocket.on("update messages") { (responses, _) in
            let dudeID = responses[0] as! String
            self.updateInfoAboutSelf {
                NotificationCenter.default.post(name: MESSAGES_UPDATED, object: nil, userInfo: ["companionID":dudeID])
            }
        }
        manager.defaultSocket.on("online") { (responses, _) in
            print("FRIEND ONLINE")
            let id = responses[0] as! String
            for (index, contact) in DataService.instance.contacts!.enumerated() {
                if contact.id == id {
                    DataService.instance.contacts![index].online = true
                }
            }
            NotificationCenter.default.post(name: CONTACT_ONLINE, object: nil, userInfo: ["id": id])
        }
        manager.defaultSocket.on("offline") { (responses, _) in
            print("FRIEND OFFLINE")
            let id = responses[0] as! String
            for (index, contact) in DataService.instance.contacts!.enumerated() {
                if contact.id == id {
                    print("CONTACT OFFLINE NOW")
                    DataService.instance.contacts![index].online = false
                }
            }
            NotificationCenter.default.post(name: CONTACT_ONLINE, object: nil, userInfo: ["id": id])
        }
        manager.defaultSocket.connect()
    }
    
    func disconnect() {
        manager.defaultSocket.disconnect()
    }
    
    func acceptFriendRequestFrom(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "friendID": id
            ]
            Alamofire.request(ACCEPT_FRIEND_REQUEST_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                self.updateInfoAboutSelf {
                    completion()
                }
            })
        }
    }
    
    func addContactWith(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "contact": id
            ]
            Alamofire.request(ADD_CONTACT_URL, method: .put, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                completion()
            })
        }
    }
    
    func deleteContactWith(id: String, completion: @escaping () -> ()) {
        DispatchQueue.global().async {
            let header = [
                "x-auth-token": DataService.instance.token!
            ]
            let body = [
                "contact": id
            ]
            Alamofire.request(DELETE_CONTACT_URL, method: .put, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                completion()
            })
        }
    }
    
    func getUserFor(email: String, completion: @escaping (User?) -> ()) {
        DispatchQueue.global().async {
            Alamofire.request(USERS_SEARCH_URL + "email=" + email, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: HEADER).responseJSON(completionHandler: { (response) in
                guard let data = response.value as? [String : Any] else { print(response); return }
                if data["error"] == nil {
                    completion(User(id: data["_id"] as! String, email: data["email"] as! String, username: data["username"] as! String, avatar: data["avatar"] as! String, publicPem: data["publicPem"] as! String, confirmed: false, requestIsMine: true, online: false))
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    func editProfileWith(username: String, andAvatar avatar: String, completion: @escaping () -> ()) {
        if DataService.instance.token != nil {
            DispatchQueue.global().async {
                let header = [
                    "x-auth-token": DataService.instance.token!
                ]
                let body = [
                    "username": username,
                    "avatar": avatar
                ]
                Alamofire.request(USERS_URL, method: .put, parameters: body, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                    guard let data = response.value as? [String : Any] else { print("response:", response); return }
                    if data["error"] == nil {
                        DataService.instance.username = username
                        DataService.instance.userAvatar = avatar
                        print("DATA CHANGED")
                        completion()
                    } else {
                        print("ERROR")
                        completion()
                    }
                })
            }
        }
    }
    
    func updateInfoAboutSelf(completion: @escaping () -> ()) {
        if DataService.instance.token != nil {
            DispatchQueue.global().async {
                let header = [
                    "x-auth-token": DataService.instance.token!
                ]
                Alamofire.request(ME_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                    guard let data = response.value as? [String : Any] else { print("bad value"); return }
                    if let error = data["error"] {
                        return print(error)
                    }
                    let user = data["user"] as! [String : Any]
                    DataService.instance.id = (user["id"] as! String)
                    DataService.instance.email = (user["email"] as! String)
                    DataService.instance.username = (user["username"] as! String)
                    DataService.instance.userAvatar = (user["avatar"] as! String)
                    DataService.instance.publicPem = (user["publicPem"] as! String)
                    DataService.instance.userMessages.removeAll()
                    let messages = user["messages"] as! [[String:Any]]
                    MessagesParser.buildMessages(messages: messages)
                    let contactsData = user["contacts"] as! [[String : Any]]
                    let contacts = contactsData.map({ (contact) -> User in
                        let _id = contact["_id"] as! String
                        let email = contact["email"] as! String
                        let username = contact["username"] as! String
                        let avatar = contact["avatar"] as! String
                        let confirmed = contact["confirmed"] as! Bool
                        let requestIsMine = contact["requestIsMine"] as! Bool
                        let publicPem = contact["publicPem"] as! String
                        return User(id: _id, email: email, username: username, avatar: avatar, publicPem: publicPem, confirmed: confirmed, requestIsMine: requestIsMine, online: false)
                    })
                    DataService.instance.contacts = contacts
                    completion()
                })
            }
        }
    }
    
    
    
    func authorizeUserWith(email: String,
                           password: String,
                           completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        DispatchQueue.global().async {
            let body = [
                "email": email,
                "password": password
            ]
            Alamofire.request(AUTH_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON(completionHandler: { (response) in
                self.dealWithAuthResponse(password: password, response: response, completion: completion)
            })
        }
    }
    
    func registerUserWith(email: String,
                          password: String,
                          username: String,
                          completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        DispatchQueue.global().async {
            do {
                let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
                guard let url = URL(string: USERS_URL) else { return }
                let defaultImageData = UIImage(named: "boy")?.pngData()
                let base64 = defaultImageData?.base64EncodedString()
                let privatePem = try keyPair.privateKey.pemString()
                let encryptedPrivatePem = try self.encryptMessage(message: privatePem, encryptionKey: password)
                print(encryptedPrivatePem)
                let body = [
                    "email": email,
                    "password": password,
                    "username": username,
                    "avatar": base64!,
                    "privatePem": encryptedPrivatePem,
                    "publicPem": try keyPair.publicKey.pemString()
                    ] as [String : Any]
                Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
                    self.dealWithRegResponse(response: response, completion: completion)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
    
    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        
        return decryptedString
    }
    
    private func dealWithRegResponse(response: DataResponse<Any>,
                                     completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        guard let data = response.value as? [String : Any] else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        completion(true, data["message"] as! String)
    }
    
    private func dealWithAuthResponse(password: String, response: DataResponse<Any>,
                                      completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        
        guard let data = response.value as? [String : Any] else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        DataService.instance.token = (data["token"] as! String)
        do {
            DataService.instance.privatePem = try self.decryptMessage(encryptedMessage: (data["privatePem"] as! String), encryptionKey: password)
            print(DataService.instance.privatePem!)
        } catch { completion(false, "Could not get private key") }
        
        updateInfoAboutSelf {
            TelegaAPI.instanse.establishConnection()
            completion(true, "Logged in as \(data["username"] as! String)")
        }
    }
}

private class MessagesParser {
    
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
                    do {
                        let encrypted = try EncryptedMessage(base64Encoded: text)
                        let privateKey = try PrivateKey(pemEncoded: DataService.instance.privatePem!)
                        let decrypted = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
                        text = try decrypted.string(encoding: .utf8)
                    } catch { text = "Bad decryption" }
                    
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
    
    private class func does(date: String, existIn tuples: [(date: String, messages: [Message])]) -> Bool {
        for tuple in tuples {
            if tuple.date == date {
                return true
            }
        }
        return false
    }
    
}
