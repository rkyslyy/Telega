//
//  User.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/5/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation
import SwiftyRSA

class User {
  let id: String
  let email: String
  var username: String
  var avatar: String
  let publicPem: String
  let publicKey: PublicKey
  var confirmed: Bool
  let requestIsMine: Bool
  var online: Bool
  var unread: Bool
  
  init(
    id: String,
    email: String,
    username: String,
    avatar: String,
    publicPem: String,
    publicKey: PublicKey,
    confirmed: Bool,
    requestIsMine: Bool,
    online: Bool,
    unread: Bool) {
    self.id = id
    self.email = email
    self.username = username
    self.avatar = avatar
    self.publicPem = publicPem
    self.publicKey = publicKey
    self.confirmed = confirmed
    self.requestIsMine = requestIsMine
    self.online = online
    self.unread = unread
  }
}
