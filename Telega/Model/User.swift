//
//  User.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/5/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

class User {
    
    init(id: String, email: String, username: String, avatar: String) {
        self.id = id
        self.email = email
        self.username = username
        self.avatar = avatar
    }
    
    let id: String
    let email: String
    let username: String
    let avatar: String
}
