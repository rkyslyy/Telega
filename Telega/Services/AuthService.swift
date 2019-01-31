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

class AuthService {
    static let instanse = AuthService()
    
    var token : String? {
        get {
            return UserDefaults.standard.string(forKey: "userToken")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userToken")
        }
    }
    
    var username : String? {
        get {
            return UserDefaults.standard.string(forKey: "username")
        } set {
            UserDefaults.standard.set(newValue, forKey: "username")
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
                self.dealWithAuthResponse(response: response, completion: completion)
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
                let body = [
                    "email": email,
                    "password": password,
                    "username": username,
                    "avatar": "base64",
                    "privatePem": try keyPair.privateKey.pemString(),
                    "publicPem": try keyPair.publicKey.pemString()
                ]
                Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON { (response) in
                    self.dealWithRegResponse(response: response, completion: completion)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func dealWithRegResponse(response: DataResponse<Any>,
                                     completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        guard let data = response.value as? [String : Any] else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        completion(true, data["message"] as! String)
    }
    
    private func dealWithAuthResponse(response: DataResponse<Any>,
                                      completion: @escaping (_ result: Bool, _ message: String) -> ()) {
        guard let data = response.value as? [String : Any] else { completion(false, "Something went wrong"); return }
        if let error = data["error"] {
            return completion(false, error as! String)
        }
        token = (data["token"] as! String)
        username = (data["username"] as! String)
        completion(true, "Logged in as \(data["username"] as! String)")
    }
}
