//
//  DataService.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/3/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation
import UIKit

enum Animation {
    case rotate
    case scale
}

class DataService {
    
    static let instance = DataService()
    
    var token : String? {
        get {
            return UserDefaults.standard.string(forKey: "userToken")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userToken")
        }
    }
    
    var id : String? {
        get {
            return UserDefaults.standard.string(forKey: "userID")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userID")
        }
    }
    
    var email : String? {
        get {
            return UserDefaults.standard.string(forKey: "email")
        } set {
            UserDefaults.standard.set(newValue, forKey: "email")
        }
    }
    
    var contacts : [User]?
    
    var privatePem : String? {
        get {
            return UserDefaults.standard.string(forKey: "privatePem")
        } set {
            UserDefaults.standard.set(newValue, forKey: "privatePem")
        }
    }
    
    var publicPem : String? {
        get {
            return UserDefaults.standard.string(forKey: "publicPem")
        } set {
            UserDefaults.standard.set(newValue, forKey: "publicPem")
        }
    }
    
    var username : String? {
        get {
            return UserDefaults.standard.string(forKey: "username")
        } set {
            UserDefaults.standard.set(newValue, forKey: "username")
        }
    }
    
    var userAvatar : String? {
        get {
            return UserDefaults.standard.string(forKey: "avatar")
        } set {
            UserDefaults.standard.set(newValue, forKey: "avatar")
        }
    }
    
    func logout() {
        token = nil
        email = nil
        privatePem = nil
        publicPem = nil
        username = nil
        userAvatar = nil
        contacts = nil
        TelegaAPI.instanse.disconnect()
    }
    
    var animatables = [(view: UIView, animation: Animation)]()
}
