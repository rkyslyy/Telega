//
//  Constants.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/30/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

// URLs
//let BASE_URL = "https://telega-rkyslyy.herokuapp.com/"
let BASE_URL = "http://localhost:3000/"
let USERS_URL = BASE_URL + "users/"
let CHANGE_PASSWORD_URL = USERS_URL + "change_password/"
let USERS_SEARCH_URL = USERS_URL + "search?"
let ME_URL = USERS_URL + "me/"
let ADD_CONTACT_URL = USERS_URL + "add_contact/"
let ACCEPT_FRIEND_REQUEST_URL = USERS_URL + "accept_friend/"
let DELETE_CONTACT_URL = USERS_URL + "delete_contact/"
let AUTH_URL = BASE_URL + "auth/"
let IMAGES_URL = BASE_URL + "images/"
let MESSAGES_URL = BASE_URL + "messages/"

// Headers
let HEADER = [
    "Content-Type": "application/json"
]

// Notifications
let CONTACTS_LOADED = Notification.Name("contacts_loaded")
let MESSAGES_UPDATED = Notification.Name("messages_updated")
