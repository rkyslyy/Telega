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

class TelegaAPI {
    static let instanse = TelegaAPI()
    
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
    
    func updateInfoAboutSelf() {
        if DataService.instance.token != nil {
            DispatchQueue.global().async {
                let header = [
                    "x-auth-token": DataService.instance.token!
                ]
                Alamofire.request(ME_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response) in
                    guard let data = response.value as? [String : Any] else { print("bad data"); return }
                    if let error = data["error"] {
                        return print(error)
                    }
                    let user = data["user"] as! [String : Any]
                    DataService.instance.email = (user["email"] as! String)
                    DataService.instance.username = (user["username"] as! String)
                    DataService.instance.userAvatar = (user["avatar"] as! String)
                    DataService.instance.privatePem = (user["privatePem"] as! String)
                    DataService.instance.publicPem = (user["publicPem"] as! String)
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
                let defaultImageData = UIImage(named: "boy")?.pngData()
                let base64 = defaultImageData?.base64EncodedString()
                let body = [
                    "email": email,
                    "password": password,
                    "username": username,
                    "avatar": base64!,
                    "privatePem": try keyPair.privateKey.pemString(),
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
        DataService.instance.token = (data["token"] as! String)
        updateInfoAboutSelf()
        completion(true, "Logged in as \(data["username"] as! String)")
    }
}
