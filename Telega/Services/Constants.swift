//
//  Constants.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/30/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

// URLs
let BASE_URL = "https://telega-rkyslyy.herokuapp.com/"
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
let HEADER = ["Content-Type": "application/json"]
var AUTH_HEADER : [String:String] {
  return ["Content-Type": "application/json",
          "x-auth-token": DataService.instance.token!]
} // Variable, but we'll not tell anyone

// Notifications
let CONTACTS_LOADED = Notification.Name("contacts_loaded")
let MESSAGES_UPDATED = Notification.Name("messages_updated")
let UPDATE_CONTACT = Notification.Name("contact_online")
let ADD_CONTACT = Notification.Name("add_contact")
let DELETE_CONTACT = Notification.Name("delete_contact")
let ACCEPT_FRIEND = Notification.Name("accept_friend")
let ONLINE_CHANGED = Notification.Name("online_changed")
let SETTINGS_CHANGED = Notification.Name("settings_changed")
let JUST_RELOAD = Notification.Name("just_reload")

// Months
let months = [
  0: "Jan",
  1: "Feb",
  2: "Mar",
  3: "Apr",
  4: "May",
  5: "Jun",
  6: "Jul",
  7: "Aug",
  8: "Sep",
  9: "Oct",
  10: "Nov",
  11: "Dec"
]
