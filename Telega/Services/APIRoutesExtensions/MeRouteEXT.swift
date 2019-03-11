//
//  MeRoute.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Alamofire
import SwiftyRSA

extension TelegaAPI {

  class func getInfoAboutSelf(completion: @escaping () -> ()) {
    if DataService.instance.token != nil {
      DispatchQueue.global().async {
        Alamofire.request(
          ME_URL,
          method: .get,
          parameters: nil,
          encoding: JSONEncoding.default,
          headers: AUTH_HEADER)
          .responseJSON { (response) in
            guard let dict = response.value as? [String : Any] else {
              return print("bad value")
            }
            if let error = dict["error"] {
              return print(error)
            }
            getDataFrom(dict)
            completion()
        }
      }
    }
  }

  class private func getDataFrom(_ dict: [String: Any]) {
    guard let user = dict["user"] as? [String : Any],
      let id = user["_id"] as? String,
      let email = user["email"] as? String,
      let username = user["username"] as? String,
      let avatar = user["avatar"] as? String,
      let publicPem = user["publicPem"] as? String,
      let contactsData = user["contacts"] as? [[String : Any]],
      let contacts = contactsFrom(contactsData),
      let messagesData = user["messages"] as? [[String:Any]],
      let publicKey = EncryptionService.publicKeyFrom(base64String: publicPem)
    else { return }
    DataService.instance.id = id
    DataService.instance.email = email
    DataService.instance.username = username
    DataService.instance.userAvatar = avatar
    DataService.instance.publicPem = publicPem
    DataService.instance.publicKey = publicKey
    DataService.instance.contacts = contacts
    MessagesStorage.buildMessagesFrom(messagesData)
    sortContacts()
  }

  class func sortContacts() {
    DataService.instance.contacts = DataService.instance.contacts!.sorted(
      by: { (one, two) -> Bool in
        let lastDateOne = MessagesStorage.getLastMessageDateOf(id: one.id)
        let lastDateTwo = MessagesStorage.getLastMessageDateOf(id: two.id)
        if lastDateOne != nil && (lastDateTwo == nil || !two.confirmed) {
          return true
        } else if (lastDateOne == nil || !one.confirmed) && lastDateTwo != nil {
          return false
        } else if lastDateOne == nil && lastDateTwo == nil {
          return true
        } else {
          return lastDateOne! >= lastDateTwo!
        }
    })
  }
  
  class private func contactsFrom(_ contactsData: [[String:Any]]) -> [User]? {
    let contacts = contactsData.compactMap({ (contact) -> User? in
      guard let _id = contact["_id"] as? String,
        let email = contact["email"] as? String,
        let username = contact["username"] as? String,
        let avatar = contact["avatar"] as? String,
        let confirmed = contact["confirmed"] as? Bool,
        let requestIsMine = contact["requestIsMine"] as? Bool,
        let publicPem = contact["publicPem"] as? String,
        let publicKey = EncryptionService.publicKeyFrom(
          base64String: publicPem),
        let online = contact["online"] as? Bool,
        let unread = contact["unread"] as? Bool
        else { return nil }
      return User(
        id: _id,
        email: email,
        username: username,
        avatar: avatar,
        publicPem: publicPem,
        publicKey: publicKey,
        confirmed: confirmed,
        requestIsMine: requestIsMine,
        online: online,
        unread: unread)
    })
    return contacts.count == contactsData.count ? contacts : nil
  }
}
